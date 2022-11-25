module arbiter_sdram (
//general input
input clk,reset,

//sdram_init_input
output [24:0]init_addr,
input init_rw,

input [15:0] init_wrdata,
input init_ac,   //acknowledge from RAM to move to next word
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
output SPI0_CS_N, SPI0_SCLK, SPI0_MOSI
);

enum logic[7:0] {Halted,Init_sdram,Init_sdram_done,
line_buffer,line_buffer_done,
background,score,key_track,note,
pcm} state,next_state;





endmodule