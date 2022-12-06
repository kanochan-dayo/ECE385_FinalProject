module arbiter_sdram (
//general input
input clk,reset,new_frame,
input [9:0] DrawY,DrawX,
input stop_sign,

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

//mem_init_input
output mem_init_sdram_wait,mem_init_sdram_ac,
input mem_init_sdram_rd,mem_init_done,
output [127:0]mem_init_sdram_data,
input [21:0]mem_init_sdram_addr,


//usb_input
input SPI0_CS_N_usb, SPI0_SCLK_usb, SPI0_MOSI_usb,
output SPI0_MISO_usb,

//I2S input
output I2S_sdram_Wait,I2S_sdram_ac,
input I2S_sdram_rd,I2S_Busy,I2S_Done,
output[127:0] I2S_sdram_data,
input [21:0] I2S_sdram_addr,

// DS input
input [127:0] DS_sdram_data,
input [21:0] DS_sdram_addr,
input DS_sdram_wr,DS_busy,DS_done,
input [15:0] DS_be,
output DS_sdram_ac,DS_sdram_wait,

//Dnum input
input [127:0] Dnum_sdram_data,
input [21:0] Dnum_sdram_addr,
input Dnum_sdram_wr,Dnum_busy,Dnum_done,
input [15:0] Dnum_sdram_be,
output Dnum_sdram_ac,Dnum_sdram_wait,


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
output SPI0_CS_N, SPI0_SCLK, SPI0_MOSI,SD_CS,start_sign
);

enum logic[7:0] 
{
	Bootup, Init_sdram, Init_sdram_done,
	Init_memory, Init_memory_done,
	Line_buffer_pre_bk, Line_buffer_pre_sp, Line_buffer_pre_nt, Line_buffer, Line_buffer_mid, Line_buffer_done,
	Background, 
	Score, Note, PCM, PCM_done,
	Halted, Done
} State, Next_state;

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
	Next_state=Init_memory;

Init_memory:
	if (mem_init_done)
		Next_state=Init_memory_done;
	
Init_memory_done:
	if (new_frame)
		Next_state=Line_buffer_pre_bk;

Line_buffer:
	if (lb_done)
	Next_state=Line_buffer_done;
	else
	if (~lb_Busy)
	Next_state=Line_buffer_mid;

Line_buffer_done:
	if(~DFJK_sdram_writedone)
		Next_state=Background;
	else if(~DS_done)
		Next_state=Score;
	else if(~Dnum_done)
		Next_state=Note;
	else
		Next_state=PCM;

Line_buffer_mid:
	
	if(~DFJK_sdram_writedone)
	Next_state=Background;
	else if (~DS_done)
	Next_state=Score;
	else if (~Dnum_done)
	Next_state=Note;
	else if (DrawX==765)
	Next_state=Line_buffer_pre_bk;
//	else
//	Next_state=Background;
	
Line_buffer_pre_bk:
	if(DrawX==799)
		Next_state=Line_buffer;

Line_buffer_pre_sp:
	if(DrawX==799)
		Next_state=Line_buffer;
Line_buffer_pre_nt:
	if(DrawX==799)
		Next_state=Line_buffer;

Background:
if (DrawX==765)
	Next_state=Line_buffer_pre_bk;

Score:
if (DrawX==765)
	Next_state=Line_buffer_pre_sp;

Note:
if (DrawX==765)
	Next_state=Line_buffer_pre_nt;



Halted:
	if (stop_sign)
		Next_state=Done;
	else if (new_frame)
		Next_state=Line_buffer_pre_bk;
		
PCM:
	if (I2S_Done)
	Next_state=PCM_done;
PCM_done:
	Next_state=Halted;
	
endcase
end

always_comb
begin:Arb

Dnum_sdram_ac=0;
Dnum_sdram_wait=1;

DS_sdram_ac=0;
DS_sdram_wait=1;

DFJK_sdram_rddata=0;
DFJK_sdram_wait=1;
DFJK_sdram_ac=0;
start_sign=0;
lb_sdram_Wait=1;
lb_sdram_ac=0;
lb_sdram_data=0;

init_wait=1;
ar_addr=0;
ar_be=16'hFFFF;
ar_read=0;
ar_write=0;
init_ac=0;
ar_wrdata=0;
SPI0_MISO_usb=SPI0_MISO;
SPI0_CS_N=SPI0_CS_N_usb;
SPI0_SCLK=SPI0_SCLK_usb;
SPI0_MOSI=SPI0_MOSI_usb;
init_miso_i=0;
SD_CS=init_cs_bo;
I2S_sdram_Wait=1;
I2S_sdram_ac=0;
I2S_sdram_data=ar_rddata;

mem_init_sdram_wait=1;
mem_init_sdram_ac=0;
mem_init_sdram_data=0;

case(State)
Bootup:
begin
	ar_wrdata=init_wrdata;
	init_ac=ar_ac;
	init_miso_i=SPI0_MISO;
	SPI0_MISO_usb=0;
	SPI0_CS_N=0;
	SPI0_SCLK=init_sclk_o;
	SPI0_MOSI=init_mosi_o;
	SD_CS=init_cs_bo;
	ar_addr=init_addr;
	ar_write=init_we;
end

Init_sdram:
begin
	ar_wrdata=init_wrdata;
	ar_addr=init_addr;
	ar_write=init_we;
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
	mem_init_sdram_wait=1;
	mem_init_sdram_ac=ar_ac;
	mem_init_sdram_data=ar_rddata;
	ar_addr=mem_init_sdram_addr;
	ar_read=mem_init_sdram_rd;
end

Init_memory:
begin
	init_wait=0;
	mem_init_sdram_wait=0;
	mem_init_sdram_ac=ar_ac;
	mem_init_sdram_data=ar_rddata;
	ar_addr=mem_init_sdram_addr;
	ar_read=mem_init_sdram_rd;
end

Init_memory_done:
begin
init_wait=0;
start_sign=1;
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
end
Background:
begin
init_wait=0;
DFJK_sdram_wait=0;
DFJK_sdram_ac=ar_ac;
ar_read=DFJK_sdram_rd;
ar_write=DFJK_sdram_wr;
DFJK_sdram_rddata=ar_rddata;
ar_wrdata=DFJK_sdram_wrdata;
ar_addr=DFJK_sdram_addr;
end
Score:
begin
init_wait=0;
DS_sdram_wait=0;
DS_sdram_ac=ar_ac;
ar_write=DS_sdram_wr;
ar_wrdata=DS_sdram_data;
ar_addr=DS_sdram_addr;
ar_be=DS_be;
end

Note:
begin
init_wait=0;
Dnum_sdram_wait=0;
Dnum_sdram_ac=ar_ac;
ar_write=Dnum_sdram_wr;
ar_wrdata=Dnum_sdram_data;
ar_addr=Dnum_sdram_addr;
ar_be=Dnum_sdram_be;
end

Line_buffer_pre_nt:
begin
init_wait=0;
Dnum_sdram_ac=ar_ac;
ar_write=Dnum_sdram_wr;
ar_wrdata=Dnum_sdram_data;
ar_addr=Dnum_sdram_addr;
ar_be=Dnum_sdram_be;
end

Line_buffer_pre_sp:
begin
init_wait=0;
DS_sdram_ac=ar_ac;
ar_write=DS_sdram_wr;
ar_wrdata=DS_sdram_data;
ar_addr=DS_sdram_addr;
ar_be=DS_be;
end

Line_buffer_pre_bk:
begin
init_wait=0;
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
