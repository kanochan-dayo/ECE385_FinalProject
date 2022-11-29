
module arbiter_sdram (
//general input
input clk,reset,new_frame,
input [9:0]DrawX,DrawY,

//sdram_init_input
input [24:0]init_addr,
input init_we,

input [15:0] init_wrdata,
output init_ac,   //acknowledge from RAM to move to next word
input init_error, //error initializing
input init_done,  //done with reading all MAX_RAM_ADDRESS words
input init_cs_bo, //SD card pins (also make sure to disable USB CS if using DE10-Lite)
input init_sclk_o,
input init_mosi_o,
output init_miso_i,

//usb_input
input SPI0_CS_N_usb, SPI0_SCLK_usb, SPI0_MOSI_usb,
output SPI0_MISO_usb,

//I2S input
output I2S_sdram_Wait,I2S_sdram_ac,
input I2S_sdram_rd,I2S_Busy,I2S_Done,
output[15:0] I2S_sdram_data,
input [24:0] I2S_sdram_addr,

//Line Buffer input
input lb_sdram_rd,lb_Busy,
output lb_sdram_Wait,lb_sdram_ac,
output [15:0] lb_sdram_data,
input [24:0] lb_sdram_addr,

//result
output [24:0] ar_addr,
output [1:0] ar_be,
output ar_read,ar_write,
input ar_ac,
output [15:0] ar_wrdata,
input [15:0] ar_rddata,

input SPI0_MISO,
output SPI0_CS_N, SPI0_SCLK, SPI0_MOSI,SD_CS
);

enum logic[7:0] {Init_sdram,Init_sdram_done,
Line_buffer,Line_buffer_mid,PCM_done,
Background,Score,Key_track,Note,
PCM,Halted} State,Next_state;

always_ff @ (posedge clk)
begin
State<=Next_state;
if(reset)
State<=Init_sdram;
end

always_comb
begin:State_transfer

Next_state=State;

case(State)

Init_sdram:
	if(init_done)
		Next_state=Halted;

Init_sdram_done:
	if (new_frame)
		Next_state=Line_buffer;
		
Line_buffer:
	if (DrawY==479)
	Next_state=PCM;
	else if (~lb_Busy)
	Next_state=Line_buffer_mid;

	
Line_buffer_mid:
	if (DrawX==799)
	Next_state=Line_buffer;
	
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


lb_sdram_Wait=1;
lb_sdram_ac=0;
lb_sdram_data=0;
ar_addr=init_addr;
ar_be=2'b11;
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
Init_sdram:
begin
init_ac=ar_ac;
init_miso_i=SPI0_MISO;
SPI0_MISO_usb=0;
SPI0_CS_N=0;
SPI0_SCLK=init_sclk_o;
SPI0_MOSI=init_mosi_o;
SD_CS=init_cs_bo;
end

PCM:
begin
I2S_sdram_Wait=0;
ar_addr=I2S_sdram_addr;
ar_read=I2S_sdram_rd;
ar_write=0;
I2S_sdram_data=ar_rddata;
I2S_sdram_ac=ar_ac;
end
Halted:
ar_write=0;
Line_buffer:
begin
ar_write=0;
lb_sdram_Wait=0;
ar_addr=lb_sdram_addr;
ar_read=lb_sdram_rd;
lb_sdram_data=ar_rddata;
lb_sdram_ac=ar_ac;
end
Line_buffer_mid:
ar_write=0;
endcase
end

endmodule
