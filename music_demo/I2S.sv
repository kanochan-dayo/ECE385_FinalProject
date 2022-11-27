module I2S
(
input LRClk,SClk,sdram_Wait, sdram_ac, reset, Clk50, new_frame, 
output sdram_rd,
input [15:0]sdram_data,
output busy,Dout,Write_done,
output [24:0] sdram_addr
);


audio_fifo adf(
	.aclr(reset),
	.data(sdram_data),
	.rdclk(~SClk),
	.rdreq(rdreq),
	.wrclk(Clk50),
	.wrreq(wrreq),
	.q(Dout),
	.wrusedw(wrusedw)
	);


logic rdreq,wrreq;
logic [10:0] wrusedw;

logic [24:0] sdram_addr_x,addr_max,addr_max_x;

logic [5:0] counter,counter_x;
logic [1:0] PreLR;

enum logic [2:0] {Halted,Init_data,Init_data2,Play,Play2,Fill,Fill2} State,Next_state;
enum logic [1:0] {Stop,Plays,PlayH} Statep,Next_statep;

always_ff @ (posedge Clk50)
begin

if (reset)
begin
State<=Halted;
sdram_addr<=25'h80000;
addr_max<=25'h80000;
end
else
begin
State<=Next_state;
sdram_addr<=sdram_addr_x;
addr_max<=addr_max_x;
end
end


always_comb
begin
Next_state=State;
addr_max_x=addr_max;
case(State)
Halted:
if(~sdram_Wait)
begin
Next_state=Init_data;
if(wrusedw>200)
addr_max_x=addr_max+1550;
else
addr_max_x=addr_max+1650;
end

Init_data:
if(sdram_ac)
Next_state=Init_data2;

Init_data2:
if(Write_done)
Next_state=Play;
else if(~sdram_ac)
Next_state=Init_data;

Play:
if (new_frame)
Next_state=Play2;

Play2:
if(~sdram_Wait)
begin
Next_state=Fill;
if(wrusedw>200)
addr_max_x=addr_max+1550;
else
addr_max_x=addr_max+1650;
end

Fill:
if(sdram_ac)
Next_state=Fill2;

Fill2:
if(Write_done)
Next_state=Play;
else if(~sdram_ac)
Next_state=Fill;

endcase
end

always_comb
begin

busy=0;
wrreq=0;
Write_done=0;
sdram_rd=0;
sdram_addr_x=sdram_addr;

case(State)
Init_data:
begin
busy=1;
sdram_rd=1;
end

Init_data2:
begin
busy=1;
wrreq=1;
sdram_addr_x=sdram_addr+1;
if(sdram_addr>=addr_max)
Write_done=1;
end

Play:
begin
Write_done=1;
end

Play2:
;

Fill:
begin
busy=1;
sdram_rd=1;
end

Fill2:
begin
busy=1;
wrreq=1;
sdram_addr_x=sdram_addr+1;
if(sdram_addr>=addr_max)
Write_done=1;
end

endcase
end

always_ff @ (posedge SClk)
begin
if (reset)
begin
Statep<=Stop;
PreLR[0]<=LRClk;
PreLR[1]<=LRClk;
end
else
begin
Statep<=Next_statep;
PreLR[0]<=LRClk;
PreLR[1]<=PreLR[0];

end
end

always_ff @ (posedge SClk)
begin
if (reset)
counter<=0;
else
counter<=counter_x;
end

always_comb
begin
Next_statep=Statep;
case (Statep)
Stop:
case (State)
Halted:Next_statep=Stop;
Init_data:Next_statep=Stop;
Init_data2:Next_statep=Stop;
default:
if(~LRClk)
Next_statep=PlayH;
endcase

PlayH:
if(counter==30)
Next_statep=Plays;

Plays:
if(counter==11)
Next_statep=PlayH;
endcase
end

always_comb
begin
case (Statep)
Plays:
rdreq=1;
default:
rdreq=0;
endcase

if(PreLR[1]==PreLR[0])
counter_x=counter+1;
else
counter_x=0;
end

endmodule