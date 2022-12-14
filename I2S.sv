module I2S
(
input LRClk,SClk,sdram_Wait, sdram_ac, reset, Clk50, new_frame, 
output sdram_rd,
input [127:0]sdram_data,
output busy,Dout,Write_done,
output [21:0] sdram_addr,
 output [7:0] wrusedw,
 output [127:0]tempdata1,
 input stop_sign
);


//fifo_a adf(
//	.data(sdram_data),
//	.rdclk(~SClk),
//	.wrclk(~Clk50),
//	.wrreq(wrreq),
//	.rdreq(rdreq),
//	.q(tempdata1),
//	.aclr(reset),
//	.wrusedw(wrusedw),
//.*
//	);
//	
fifo_a_ram adf(
	.rdaddress(rdaddress[7:0]),
	.wraddress(wraddress[7:0]),
	.wren(wrreq),
	.data(sdram_data),
	.rdclock(~SClk),
	.wrclock(~Clk50),
	.q(tempdata1));

logic [8:0]  rdaddress,wraddress,rdaddress_x,wraddress_x;

assign wrusedw=(rdaddress[8]==wraddress[8])?(wraddress[7:0]-rdaddress[7:0]):(256+wraddress[7:0]-rdaddress[7:0]);

logic [127:0] tempdata;

	always_ff @ (posedge rdreq)
	begin
	tempdata<=tempdata1;
	end

	
logic rdreq,wrreq;

logic [21:0] sdram_addr_x,addr_max,addr_max_x;

logic [7:0] counter,counter_x,counters;
logic [1:0] PreLR;
logic Play_flag;

enum logic [2:0] {Halted,Init_data,Init_data2,Play,Play2,Fill,Fill2,Stoped} State,Next_state;
enum logic [2:0] {Stop,Plays,PlayH} Statep,Next_statep;

initial
begin
sdram_addr=23'h00000;
addr_max=23'h00000;
end

always_ff @ (posedge Clk50)
begin

if (reset)
begin
wraddress<=0;
State<=Halted;
sdram_addr<=23'h00000;
addr_max<=23'h00000;
end
else
begin
wraddress<=wraddress_x;
State<=Next_state;
sdram_addr<=sdram_addr_x;
addr_max<=addr_max_x;
end
end


always_comb
begin
wraddress_x=wraddress;
Next_state=State;
addr_max_x=addr_max;
case(State)
Halted:
if(~sdram_Wait)
begin
Next_state=Init_data;
addr_max_x=addr_max+200;
end

Init_data:
if(sdram_ac)
Next_state=Init_data2;

Init_data2:
begin
wraddress_x=wraddress+1;
if(sdram_addr==addr_max)
Next_state=Play;
else 
begin
Next_state=Init_data;
end
end

Play:
if (new_frame)
Next_state=Play2;

Play2:
if(stop_sign)
Next_state=Stoped;
else
if(~sdram_Wait)
begin
Next_state=Fill;
addr_max_x=addr_max+200-wrusedw;
end


Fill:
if(sdram_ac)
Next_state=Fill2;

Fill2:
begin
wraddress_x=wraddress+1;
if(sdram_addr==addr_max)
Next_state=Play;
else
Next_state=Fill;
end
Stop:
begin
wraddress_x=0;
addr_max_x=0;
end
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

Stoped:
begin
Write_done=1;
Play_flag=0;
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
rdaddress<=0;
counter<=0;
end
else
begin
rdaddress<=rdaddress_x;
counter<=counter_x;
end
end

always_comb
begin
rdaddress_x=rdaddress;
Next_statep=Statep;
case (Statep)
Stop:
begin
rdaddress_x=0;
if(Play_flag)
begin
if(LRClk)
Next_statep=PlayH;
end
else
Next_statep=Statep;
end


PlayH:
if (Play_flag)
begin
if(counter==252)
Next_statep=Plays;
end
else
Next_statep=Stop;

Plays:
begin
rdaddress_x=rdaddress+1;
if (Play_flag)
Next_statep=PlayH;
else
Next_statep=Stop;
end
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
counter_x[7:5]=counter[7:5];
end

if(counters[4]==1||stop_sign)
Dout=0;
else
Dout=tempdata[(15+(counters[7:5]<<4))-counters[3:0]];
end

always_ff @ (negedge SClk)
begin
counters=counter;
end


endmodule











