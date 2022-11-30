
module arbiter_sdram (
//general input
input clk,reset,new_frame,

//sdram_init_input
input [22:0]init_addr,
input init_we,

input [63:0] init_wrdata,
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
output[63:0] I2S_sdram_data,
input [22:0] I2S_sdram_addr,

//result
output [22:0] ar_addr,
output [7:0] ar_be,
output ar_read,ar_write,
input ar_ac,
output [63:0] ar_wrdata,
input [63:0] ar_rddata,

input SPI0_MISO,
output SPI0_CS_N, SPI0_SCLK, SPI0_MOSI,SD_CS
);

enum logic[7:0] {Bootup,Init_sdram,Init_sdram_done,
Line_buffer,Line_buffer_done,
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
		Next_state=PCM;
PCM:
// Next_state=PCM;
	if (I2S_Done)
	Next_state=Halted;

Halted:
	if (new_frame)
		Next_state=PCM;

endcase
end

always_comb
begin:Arb
init_wait=1;
ar_addr=init_addr;
ar_be=8'b11111111;
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
init_wait=1;
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
ar_addr=I2S_sdram_addr;
ar_read=I2S_sdram_rd;
ar_write=0;
I2S_sdram_data=ar_rddata;
I2S_sdram_ac=ar_ac;
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
ar_addr=I2S_sdram_addr;
I2S_sdram_ac=ar_ac;
end
endcase
end

endmodule
