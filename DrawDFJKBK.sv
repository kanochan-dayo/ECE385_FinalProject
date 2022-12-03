module DrawDFJK_BK(
input new_frame,clk,sdram_wait,sdram_ac, reset,frame_flip,
input [3:0] DFJK,
output sdram_rd,sdram_wr,busy,writedone,
input [127:0] sdram_rddata,
output[127:0] sdram_wrdata,
output[21:0] sdram_addr
);

parameter rdaddr_offset=22'h300000;
parameter rdaddr_shift_offset=13'h1E00;
parameter wraddr_offset0=22'h100000;
parameter wraddr_offset1=22'h200000;
parameter wraddr_shift_offset=6'h18;
parameter wraddr_max1=22'h200000+22'd19175;
parameter wraddr_max0=22'h100000+22'd19175;

enum logic [3:0]{Halted,Read,Read1,Write,Write1,Pause,Done} State,Next_state;
logic [21:0] sdram_rdaddr_x,sdram_wraddr_x,sdram_rdaddr,sdram_wraddr;
logic prestate,prestate_x;
logic [3:0]sdram_wraddr_trace_x,sdram_wraddr_trace;
logic [21:0]wraddr_max;
assign wraddr_max=frame_flip?wraddr_max1:wraddr_max0;

always_comb
begin
sdram_addr=0;
case(State)
Read:
sdram_addr=sdram_rdaddr;
Read1:
sdram_addr=sdram_wraddr;
Write:
sdram_addr=sdram_wraddr;
Write1:
sdram_addr=sdram_rdaddr;
endcase
end

always_ff @(negedge sdram_ac or posedge reset)
begin
if(reset)
sdram_wrdata<=0;
else
sdram_wrdata<=sdram_rddata;
end

always_ff @(posedge clk)
begin
if (reset)
begin
prestate<=0;
sdram_rdaddr<=rdaddr_offset;
sdram_wraddr<=wraddr_offset0;
sdram_wraddr_trace<=0;
State<=Halted;
end
else
begin
prestate<=prestate_x;
sdram_rdaddr<=sdram_rdaddr_x;
sdram_wraddr<=sdram_wraddr_x;
sdram_wraddr_trace<=sdram_wraddr_trace_x;
State<=Next_state;
end
end

always_comb
begin
Next_state=State;

case(State)
Halted:
if(~sdram_wait)
Next_state=Read;

Read:
if(sdram_ac)
Next_state=Read1;

Read1:
if (sdram_wait)
Next_state=Pause;
else
Next_state=Write;

Write:
if(sdram_ac)
Next_state=Write1;

Write1:
if(sdram_wraddr_x==wraddr_max)
Next_state=Done;
else if (sdram_wait)
Next_state=Pause;
else
Next_state=Read;

Pause:
if(~sdram_wait)
begin
case(prestate)
0:
Next_state=Write;
1:
Next_state=Read;
endcase
end

Done:
if(new_frame)
Next_state=Halted;
endcase
end

always_comb
begin
sdram_rd=0;
sdram_wr=0;
busy=0;
writedone=0;
prestate_x=prestate;
sdram_rdaddr_x=sdram_rdaddr;
sdram_wraddr_x=sdram_wraddr;
sdram_wraddr_trace_x=sdram_wraddr_trace;
case(State)
Halted:
begin
sdram_wraddr_trace_x=0;
sdram_rdaddr_x=rdaddr_offset+rdaddr_shift_offset*DFJK;
sdram_wraddr_x=frame_flip?wraddr_offset1:wraddr_offset0;
end
Read:
begin
busy=1;
sdram_rd=1;
prestate_x=0;
end

Read1:
begin
busy=1;
sdram_rdaddr_x=sdram_rdaddr+1;
prestate_x=0;
end

Write:
begin
prestate_x=1;
busy=1;
sdram_wr=1;
end

Write1:
begin
sdram_wraddr_x=(sdram_wraddr_trace==4'hF)?(sdram_wraddr+1+wraddr_shift_offset):(sdram_wraddr+1);
sdram_wraddr_trace_x=sdram_wraddr_trace+1;
prestate_x=1;
busy=1;
end

Pause:
;

Done:
begin
writedone=1;
sdram_wraddr_trace_x=0;
sdram_rdaddr_x=rdaddr_offset+rdaddr_shift_offset*DFJK;
sdram_wraddr_x=frame_flip?wraddr_offset1:wraddr_offset0;
end
endcase
end

endmodule