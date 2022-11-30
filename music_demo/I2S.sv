module I2S
(
input LRClk,SClk,sdram_Wait, sdram_ac, reset, Clk50, new_frame, 
output sdram_rd,
input [63:0]sdram_data,
output busy,Dout,Write_done,
output [22:0] sdram_addr,
output [63:0] tempdata1,
 output [10:0] wrusedw
);


fifo_a adf(
	.data(sdram_data),
	.rdclk(~SClk),
	.wrclk(~Clk50),
	.wrreq(wrreq),
	.rdreq(rdreq),
	.q(tempdata1),
	.aclr(reset),
	.wrusedw(wrusedw),
.*
	);
	
	


	always_ff @ (posedge rdreq)
	begin
	tempdata<=tempdata1;
	end

	
logic [63:0] tempdata;

logic rdreq,wrreq;

logic [22:0] sdram_addr_x,addr_max,addr_max_x;

logic [6:0] counter,counter_x,counters;
logic [1:0] PreLR;
logic Play_flag;

enum logic [2:0] {Halted,Init_data,Init_data2,Play,Play2,Fill,Fill2} State,Next_state;
enum logic [2:0] {Stop,Plays,PlayH} Statep,Next_statep;

initial
begin
sdram_addr=23'h20000;
addr_max=23'h20000;
end

always_ff @ (posedge Clk50)
begin

if (reset)
begin
State<=Halted;
sdram_addr<=23'h20000;
addr_max<=23'h20000;
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
addr_max_x=addr_max+425;
end

Init_data:
if(sdram_ac)
Next_state=Init_data2;

Init_data2:
if(sdram_addr==addr_max)
Next_state=Play;
else 
begin
Next_state=Init_data;
end


Play:
if (new_frame)
Next_state=Play2;

Play2:
if(~sdram_Wait)
begin
Next_state=Fill;
addr_max_x=addr_max+425-wrusedw;
end


Fill:
if(sdram_ac)
Next_state=Fill2;

Fill2:
if(sdram_addr==addr_max)
Next_state=Play;
else
Next_state=Fill;

endcase
end

always_comb
begin
Play_flag=1;
busy=0;
wrreq=0;
Write_done=0;
sdram_rd=0;
sdram_addr_x=sdram_addr;

case(State)
Halted:
Play_flag=0;

Init_data:
begin
Play_flag=0;
busy=1;
sdram_rd=1;
end

Init_data2:
begin
Play_flag=0;
busy=1;
wrreq=1;
sdram_addr_x=sdram_addr+1;
if(sdram_addr==addr_max)
Write_done=1;
end


Play:
begin
Write_done=1;
end


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
if(sdram_addr==addr_max)
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
begin

counter<=0;
end
else
begin
counter<=counter_x;

end
end

always_comb
begin

Next_statep=Statep;
case (Statep)
Stop:
if(Play_flag)
begin
if(LRClk)
Next_statep=PlayH;
end
else
Next_statep=Statep;


PlayH:
if (Play_flag)
begin
if(counter==124)
Next_statep=Plays;
end
else
Next_statep=Stop;

Plays:
if (Play_flag)
Next_statep=PlayH;
else
Next_statep=Stop;

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
begin
counter_x[4:0]=1;
counter_x[6:5]=counter[6:5];
end

if(counters[4]==1)
Dout=0;
else
Dout=tempdata[(15+(counters[6:5]<<4))-counters[3:0]];
end

always_ff @ (negedge SClk)
begin
counters=counter;
end


endmodule











