module mem_init(
input clk,reset,sdram_wait,sdram_ac,
input [127:0] sdram_data,
output [127:0] mem_data,
output [21:0] sdram_addr,
output [8:0] mem_addr,
output mem_init_done,mem_wr,sdram_rd);

parameter sdram_offset=22'h310000;
parameter mem_addr_max=9'h100;



enum logic [2:0]{Halted,Read,Read1,Write1,Done} State,Next_state;
logic [21:0] sdram_addr_x;
logic [8:0]mem_addr_x;


always_ff @(negedge sdram_ac or posedge reset)
begin
	if(reset)
	mem_data<=0;
	else
	mem_data<=sdram_data;
end


always_ff @(posedge clk)
begin
	if (reset)
	begin
		sdram_addr<=sdram_offset;
		mem_addr<=0;
		State<=Halted;
	end
	else
	begin
		sdram_addr<=sdram_addr_x;
		mem_addr<=mem_addr_x;
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
Next_state=Write1;

Write1:
if(mem_addr==mem_addr_max)
Next_state=Done;
else
Next_state=Read;


Done:
;
endcase
end

always_comb
begin
sdram_rd=0;
mem_wr=0;
mem_init_done=0;
sdram_addr_x=sdram_addr;
mem_addr_x=mem_addr;

case(State)
Halted:
begin
sdram_addr_x=sdram_offset;
mem_addr_x=0;
end

Read:
begin
sdram_rd=1;
end

Read1:
begin
sdram_addr_x=sdram_addr+1;
end

Write1:
begin
mem_wr=1;
mem_addr_x=mem_addr+1;
end

Done:
begin
mem_init_done=1;
sdram_addr_x=sdram_offset;
mem_addr_x=0;
end
endcase
end

endmodule