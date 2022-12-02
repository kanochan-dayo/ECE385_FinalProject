module arbiter_sdram (
//general input
input clk,reset,new_frame,
input [9:0] DrawY,DrawX,

//sdram_init_input
input [21:0]init_addr,
input init_we,

input [127:0] init_wrdata,
output init_ac,   //acknowledge from RAM to move to next word
input init_error, //error initializing
input init_done,  //done with reading all MAX_RAM_ADDRESS words
input init_cs_bo, //SD card pins (also make sure to disable USB CS if using DE10-Lite)
input init_sclk_o,
input init_mosi_o,
output init_miso_i,
init_wait,

//usb_input
input SPI0_CS_N_usb, SPI0_SCLK_usb, SPI0_MOSI_usb,
output SPI0_MISO_usb,

//I2S input
output I2S_sdram_Wait,I2S_sdram_ac,
input I2S_sdram_rd,I2S_Busy,I2S_Done,
output[127:0] I2S_sdram_data,
input [21:0] I2S_sdram_addr,

//BK input
output DFJK_sdram_wait,DFJK_sdram_ac,
input DFJK_sdram_rd,DFJK_sdram_wr,DFJK_busy,DFJK_sdram_writedone,
output [127:0]DFJK_sdram_rddata,
input [127:0]DFJK_sdram_wrdata,
input [21:0]DFJK_sdram_addr,

//Line Buffer input
input lb_sdram_rd,lb_Busy,lb_done,
output lb_sdram_Wait,lb_sdram_ac,
output [127:0] lb_sdram_data,
input [21:0] lb_sdram_addr,

//result
output [21:0] ar_addr,
output [15:0] ar_be,
output ar_read,ar_write,
input ar_ac,
output [127:0] ar_wrdata,
input [127:0] ar_rddata,

input SPI0_MISO,
output SPI0_CS_N, SPI0_SCLK, SPI0_MOSI,SD_CS
);

enum logic[7:0] {Bootup,Init_sdram,Init_sdram_done,
Init_memory,Init_memory_done,Line_buffer,Line_buffer_mid,Line_buffer_pre,PCM_done,
Background,Score,Key_track,Note,
PCM,Halted} State,Next_state;

always_ff @ (posedge clk)
begin
State<=Next_state;
if(reset)
State<=Bootup;
end
initial
begin
init_wait=1;
end

always_comb
begin:State_transfer

Next_state=State;

case(State)

Bootup:
if (new_frame)
Next_state=Init_sdram;

Init_sdram:
	if(init_done)
		Next_state=Init_sdram_done;

Init_sdram_done:
	if (new_frame)
		Next_state=Line_buffer;

Line_buffer:
	if (lb_done)
	begin
	if(~DFJK_sdram_writedone)
	Next_state=Background;
	else
	Next_state=PCM;
	end
	else
	if (~lb_Busy)
	Next_state=Line_buffer_mid;

	
Line_buffer_mid:
	
	if(~DFJK_sdram_writedone)
	Next_state=Background;
	else if (DrawX==790)
	Next_state=Line_buffer_pre;
//	else
//	Next_state=Background;
	
Line_buffer_pre:
	if(~DFJK_busy)
		Next_state=Line_buffer;

Background:
	if(DFJK_sdram_writedone)
	Next_state=Line_buffer;
	else if (DrawY<479&&DrawX==790)
	Next_state=Line_buffer_pre;


Halted:
	if (new_frame)
		Next_state=Line_buffer;
PCM:
	if (I2S_Done)
	Next_state=PCM_done;
PCM_done:
	Next_state=Halted;
	
endcase
end

always_comb
begin:Arb
DFJK_sdram_rddata=0;
DFJK_sdram_wait=1;
DFJK_sdram_ac=0;

lb_sdram_Wait=1;
lb_sdram_ac=0;
lb_sdram_data=0;

init_wait=1;
ar_addr=init_addr;
ar_be=16'hFFFF;
ar_read=0;
ar_write=init_we;
init_ac=0;
ar_wrdata=init_wrdata;
SPI0_MISO_usb=SPI0_MISO;
SPI0_CS_N=SPI0_CS_N_usb;
SPI0_SCLK=SPI0_SCLK_usb;
SPI0_MOSI=SPI0_MOSI_usb;
init_miso_i=0;
SD_CS=init_cs_bo;
I2S_sdram_Wait=1;
I2S_sdram_ac=0;
I2S_sdram_data=ar_rddata;

case(State)
Bootup:
begin
	init_ac=ar_ac;
	init_miso_i=SPI0_MISO;
	SPI0_MISO_usb=0;
	SPI0_CS_N=0;
	SPI0_SCLK=init_sclk_o;
	SPI0_MOSI=init_mosi_o;
	SD_CS=init_cs_bo;
end

Init_sdram:
begin
	init_wait=0;
	init_ac=ar_ac;
	init_miso_i=SPI0_MISO;
	SPI0_MISO_usb=0;
	SPI0_CS_N=0;
	SPI0_SCLK=init_sclk_o;
	SPI0_MOSI=init_mosi_o;
	SD_CS=init_cs_bo;
end

Init_sdram_done:
begin
	init_wait=0;
	ar_write=0;
	lb_sdram_Wait=0;
	ar_addr=lb_sdram_addr;
	ar_read=lb_sdram_rd;
	lb_sdram_data=ar_rddata;
	lb_sdram_ac=ar_ac;
end

PCM:
begin
	init_wait=0;
	I2S_sdram_Wait=0;
	ar_addr=I2S_sdram_addr;
	ar_read=I2S_sdram_rd;
	ar_write=0;
	I2S_sdram_data=ar_rddata;
	I2S_sdram_ac=ar_ac;
end

Halted:
begin
	init_wait=0;
	ar_write=0;
end

Line_buffer:
begin
	init_wait=0;
	ar_write=0;
	lb_sdram_Wait=0;
	ar_addr=lb_sdram_addr;
	ar_read=lb_sdram_rd;
	lb_sdram_data=ar_rddata;
	lb_sdram_ac=ar_ac;
end
Line_buffer_mid:
begin
init_wait=0;
ar_write=0;
end
Background:
begin
DFJK_sdram_wait=0;
DFJK_sdram_ac=ar_ac;
ar_read=DFJK_sdram_rd;
ar_write=DFJK_sdram_wr;
DFJK_sdram_rddata=ar_rddata;
ar_wrdata=DFJK_sdram_wrdata;
ar_addr=DFJK_sdram_addr;
end
Line_buffer_pre:
begin
DFJK_sdram_ac=ar_ac;
ar_read=DFJK_sdram_rd;
ar_write=DFJK_sdram_wr;
DFJK_sdram_rddata=ar_rddata;
ar_wrdata=DFJK_sdram_wrdata;
ar_addr=DFJK_sdram_addr;
end
endcase
end

endmodule
