module arbiter_sdram (
//general input
input clk,reset,new_frame,

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
Line_buffer,Line_buffer_done,
Background,Score,Key_track,Note,
PCM,Halted} State,Next_state;

always_ff @ (posedge clk)
begin
State<=Next_state;
end

always_comb
begin:State_transfer

Next_state=State;
if(reset)
Next_state=Init_sdram;
else
case(State)

Init_sdram:
	if(init_done)
		Next_state=Halted;

Init_sdram_done:
	if (new_frame)
		Next_state=PCM;
PCM:
//	if (PCM_done)
	Next_state=Halted;

Halted:
	if (new_frame)
		Next_state=PCM;

endcase
end

always_comb
begin:Arb

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
endcase
end

endmodule