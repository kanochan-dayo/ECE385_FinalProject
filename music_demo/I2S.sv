/*module I2S
(
input LRClk,SClk,sdram_Wait, sdram_ac, reset, Clk50, new_frame, 
output sdram_rd,
input [15:0]sdram_data,
output busy,Dout,Write_done,rdempty,wrfull,
output [24:0] sdram_addr,
 output [10:0] wrusedw
);


fifo_audio adf(
	.data(sdram_data),
	.rdclock(~SClk),
	.wrclock(~Clk50),
	.wren(wrreq),
	.q(tempdata1),
.*
	);
logic [10:0] rdaddress,wraddress;
logic [10:0] rdaddress_x,wraddress_x;

always_ff @ (negedge LRClk)
begin
if(State==Halted||State==Init_data3||State==Init_data||State==Init_data2)

begin
wrusedw_x<=1580;
wrusedw<=1580;
Flag_c<=0;
end

else if(Flag_i==1&&Flag_c==0)
begin
Flag_c<=1;
if(wrusedw<201)
wrusedw_x<=1613+wrusedw;
else
wrusedw_x<=1548+wrusedw;

if(wrusedw_x<201)
wrusedw<=1613+wrusedw_x;
else
wrusedw<=1548+wrusedw_x;
end



else if(Flag_i==0&&Flag_c==1)
begin
Flag_c<=0;
wrusedw_x<=-2+wrusedw;
wrusedw<=-2+wrusedw_x;
end

else
begin
wrusedw_x<=-2+wrusedw;
wrusedw<=-2+wrusedw_x;
end

end

	always_ff @ (negedge rdreq)
	begin
	tempdata<=tempdata1;
	end
	
logic [15:0] tempdata,tempdata1;

logic rdreq,wrreq;
logic [10:0] wrusedw_x;

logic [24:0] sdram_addr_x,addr_max,addr_max_x;

logic [4:0] counter,counter_x,counters;
logic [1:0] PreLR;
logic Play_flag,Flag_i,Flag_c;

enum logic [6:0] {Halted,Init_data,Init_data2,Init_data3,Play,Play2,Playrr,Fill,Fill2,Fill3} State,Next_state;
enum logic [2:0] {Stop,Plays,PlayH} Statep,Next_statep;

initial
begin
sdram_addr=25'h80000;
addr_max=25'h80000;
end

always_ff @ (posedge Clk50)
begin

if (reset)
begin
State<=Halted;
sdram_addr<=25'h80000;
addr_max<=25'h80000;
wraddress<=0;
end
else
begin
State<=Next_state;
sdram_addr<=sdram_addr_x;
addr_max<=addr_max_x;
wraddress<=wraddress_x;
end
end


always_comb
begin
Next_state=State;
addr_max_x=addr_max;
wraddress_x=wraddress;
case(State)
Halted:
if(~sdram_Wait)
begin
Next_state=Init_data;
addr_max_x=addr_max+1580;
end

Init_data:
if(sdram_ac)
Next_state=Init_data2;

Init_data2:
Next_state=Init_data3;

Init_data3:
begin
if(Write_done)
Next_state=Playrr;
else 
begin
Next_state=Init_data;
wraddress_x=wraddress+1;
end
end

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
addr_max_x=addr_max+1615;
end

Fill:
if(sdram_ac)
Next_state=Fill2;

Fill2:
Next_state=Fill3;

Fill3:
begin
if(Write_done)
Next_state=Playrr;
else 
begin
Next_state=Fill;
wraddress_x=wraddress+1;
end

end

Playrr:
begin
Next_state=Play;
wraddress_x=wraddress+1;
end
endcase
end

always_comb
begin
Flag_i=0;
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
end

Init_data3:
begin
Play_flag=0;
busy=1;
wrreq=1;
if(sdram_addr==addr_max)
Write_done=1;
end


Play:
begin
Write_done=1;
end


Fill:
begin
Flag_i=1;
busy=1;
sdram_rd=1;
end

Fill2:
begin
Flag_i=1;
busy=1;
wrreq=1;
sdram_addr_x=sdram_addr+1;
end

Fill3:
begin
Flag_i=1;
busy=1;
wrreq=1;
if(sdram_addr==addr_max)
Write_done=1;
end

Playrr:
begin
wrreq=1;
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
rdaddress<=0;
counter<=0;
end
else
begin
counter<=counter_x;
rdaddress<=rdaddress_x;
end
end

always_comb
begin
rdaddress_x=rdaddress;
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
if(counter==28)
Next_statep=Plays;
end
else
Next_statep=Stop;

Plays:
if (Play_flag)
begin
if(counter==31)
begin
rdaddress_x=rdaddress+1;
Next_statep=PlayH;
end
end
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
counter_x=1;

if(counters[4]==1)
Dout=0;
else
Dout=tempdata[15-counters[3:0]];
end

always_ff @ (negedge SClk)
begin
counters=counter;
end


endmodule
*/
module I2S
(
input LRClk,SClk,sdram_Wait, sdram_ac, reset, Clk50, new_frame, 
output sdram_rd,
input [15:0]sdram_data,
output busy,Dout,Write_done,rdempty,wrfull,
output [24:0] sdram_addr,
output [15:0] tempdata1,
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

	
logic [15:0] tempdata;

logic rdreq,wrreq;

logic [24:0] sdram_addr_x,addr_max,addr_max_x;

logic [4:0] counter,counter_x,counters;
logic [1:0] PreLR;
logic Play_flag,Flag_i;

enum logic [6:0] {Halted,Init_data,Init_data2,Init_data3,Play,Play2,Playrr,Fill,Fill2,Fill3} State,Next_state;
enum logic [2:0] {Stop,Plays,PlayH} Statep,Next_statep;

initial
begin
sdram_addr=25'h80000;
addr_max=25'h80000;
end

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
addr_max_x=addr_max+1700;
end

Init_data:
if(sdram_ac)
Next_state=Init_data2;

Init_data2:
Next_state=Init_data3;

Init_data3:
begin
if(sdram_addr==addr_max)
Next_state=Playrr;
else 
begin
Next_state=Init_data;
end
end

Play:
if (new_frame)
Next_state=Play2;

Play2:
if(~sdram_Wait)
begin
Next_state=Fill;
addr_max_x=addr_max+1700-wrusedw;
end


Fill:
if(sdram_ac)
Next_state=Fill2;

Fill2:
Next_state=Fill3;

Fill3:
begin
if(sdram_addr==addr_max)
Next_state=Playrr;
else 
begin
Next_state=Fill;
end

end

Playrr:
begin
Next_state=Play;
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
//wrreq=1;
sdram_addr_x=sdram_addr+1;
if(sdram_addr==addr_max)
Write_done=1;
end

Init_data3:
begin
wrreq=1;
Play_flag=0;
busy=1;
end


Play:
begin
Write_done=1;
end


Fill:
begin
Flag_i=1;
busy=1;
sdram_rd=1;
end

Fill2:
begin
Flag_i=1;
busy=1;
//wrreq=1;
sdram_addr_x=sdram_addr+1;
if(sdram_addr==addr_max)
Write_done=1;
end

Fill3:
begin
Flag_i=1;
busy=1;
wrreq=1;

end

Playrr:
begin
Write_done=1;
//wrreq=1;
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
if(counter==28)
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
counter_x=1;

if(counters[4]==1)
Dout=0;
else
Dout=tempdata[15-counters[3:0]];
end

always_ff @ (negedge SClk)
begin
counters=counter;
end


endmodule











