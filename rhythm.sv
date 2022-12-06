//-------------------------------------------------------------------------
//      ECE 385 - Summer 2021 Lab 7 Top-level                            --
//                                                                       --
//      Updated Fall 2021 as Lab 7                                       --
//      For use with ECE 385                                             --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module rhythm (

      ///////// Clocks /////////
      input    MAX10_CLK1_50,
		input    MAX10_CLK2_50,

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,





      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);

//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [7:0] keycode;
	logic [3:0] DFJK,DFJK_x;
	logic [9:0] LEDRR;
	logic SD_CS;
	assign LEDR[9:6]=LEDRR[9:6];
	assign LEDR[4:1]=DFJK;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
//	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ;
	assign USB_IRQ = ARDUINO_IO[9];
	
	//Assignments specific to Sparkfun USBHostShield-v13
	//assign ARDUINO_IO[7] = USB_RST;
	//assign ARDUINO_IO[8] = 1'bZ;
	//assign USB_GPX = ARDUINO_IO[8];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[8] = 1'bZ;
	
	assign ARDUINO_IO[6]=SD_CS;
	//GPX is unconnected to shield, not needed for standard USB host - set to 0 to prevent interrupt
	assign USB_GPX = 1'b0;
	
	//HEX drivers to convert numbers to HEX output
		
	HexDriver hex_driver5 ({2'b00,ar_addr[21:20]}, HEX5[6:0]);
	assign HEX5[7] = 1'b1;
	
	HexDriver hex_driver4 (ar_addr[19:16], HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (tempdata1[15:12], HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver2 (tempdata1[11:8], HEX2[6:0]);
	assign HEX2[7] = 1'b1;
	
	HexDriver hex_driver1 (tempdata1[7:4], HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (tempdata1[3:0], HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
//	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
//	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
assign i2c_serial_scl_in = ARDUINO_IO[15];
assign ARDUINO_IO[15] = i2c_serial_scl_oe ? 1'b0 : 1'bz;
assign i2c_serial_sda_in = ARDUINO_IO[14];
assign ARDUINO_IO[14] = i2c_serial_sda_oe ? 1'b0 : 1'bz;

	assign {Reset_h}=~ (KEY[0]); 

	//assign signs = 2'b00;
	//assign hex_num_4 = 4'h4;
	//assign hex_num_3 = 4'h3;
	//assign hex_num_1 = 4'h1;
	//assign hex_num_0 = 4'h0;
	
	//remember to rename the SOC as necessary
	rhythm_soc u0 (
		.clk_clk                           (MAX10_CLK1_50),    //clk.clk
		.reset_reset_n                     (KEY[0]),             //reset.reset_n
		.altpll_0_locked_conduit_export    (),    			   //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (), 				   //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),     			   //altpll_0_areset_conduit.export
    
		.key_external_connection_export    (KEY),    		   //key_external_connection.export

		//SDRAM


		//USB SPI	
		
//		.spi0_SS_n(SPI0_CS_N),
//		.spi0_MOSI(SPI0_MOSI),
//		.spi0_MISO(SPI0_MISO),
//		.spi0_SCLK(SPI0_SCLK),
		
		.spi0_SS_n(SPI0_CS_N_usb),
		.spi0_MOSI(SPI0_MOSI_usb),
		.spi0_MISO(SPI0_MISO_usb),
		.spi0_SCLK(SPI0_SCLK_usb),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDRR}),
		.keycode_export(keycode),
		
		//I2C
		.i2c_sda_in(i2c_serial_sda_in),                     //                     i2c.sda_in
		.i2c_scl_in(i2c_serial_scl_in),                     //                        .scl_in
		.i2c_sda_oe(i2c_serial_sda_oe),                     //                        .sda_oe
		.i2c_scl_oe(i2c_serial_scl_oe), 
		


		// DFJK
		.key_dfjk_export(DFJK_x),
		
		
	 );

vga_controller vga_ctr(     .Clk(MAX10_CLK1_50),       // 50 MHz clock
.Reset(Reset_h),     // reset signal
.hs(VGA_HS),       
.vs(VGA_VS),      										 
.* );   
//background_mapper bk(.*,.clock(MAX10_CLK1_50));
//
logic [9:0] DrawX, DrawY;
logic pixel_clk,blank,sync;

always_ff @ (posedge new_frame)
begin
DFJK<=DFJK_x;
end

sdram_contorller sdram1(
		.sdram_clk_clk(DRAM_CLK),            				   //clk_sdram.clk
	   .sdram_wire_addr(DRAM_ADDR),               			   //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                			   //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),              		   //.cas_n
		.sdram_wire_cke(DRAM_CKE),                 			   //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                		   //.cs_n
		.sdram_wire_dq(DRAM_DQ),                  			   //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),                //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),              		   //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                		   //.we_n
		.bridge_address({ar_addr,4'b0000}),     //     bridge.address
		.bridge_byte_enable(ar_be), //           .byte_enable
		.bridge_read(ar_read),        //           .read
		.bridge_write(ar_write),       //           .write
		.bridge_write_data(ar_wrdata),  //           .write_data
		.bridge_acknowledge(ar_ac), //           .acknowledge
		.bridge_read_data(ar_rddata),   //           .read_data
		.clk_clk(MAX10_CLK1_50),            //        clk.clk
		.reset_reset_n(KEY[0])
		);

logic [21:0] ar_addr,init_addr;
logic [15:0] ar_be;
logic ar_read,ar_write,ar_ac;
logic [127:0] ar_wrdata,ar_rddata,init_data;
logic init_we,init_ac,init_done,init_cs_bo,init_sclk_o,init_mosi_o,init_miso_i,init_error;
logic [127:0] init_wrdata;
logic SPI0_CS_N_usb, SPI0_SCLK_usb, SPI0_MISO_usb, SPI0_MOSI_usb;

sdcard_init sd_init(.clk50(MAX10_CLK1_50),
	.reset(Reset_h),          //starts as soon reset is deasserted
	.ram_we(init_we),         //RAM interface pins
	.ram_address(init_addr),
	.ram_data(init_wrdata),
	.ram_op_begun(init_ac),   			//acknowledge from RAM to move to next word
	.ram_init_error(init_error), 		//error initializing
	.ram_init_done(init_done),  		//done with reading all MAX_RAM_ADDRESS words
	.cs_bo(init_cs_bo), 					//SD card pins (also make sure to disable USB CS if using DE10-Lite)
	.sclk_o(init_sclk_o),
	.mosi_o(init_mosi_o),
	.miso_i(init_miso_i),.*  );
	
	
arbiter_sdram arbiter(.*,.clk(MAX10_CLK1_50),.reset(Reset_h));
mem_init init_mem(
.clk(MAX10_CLK1_50),.reset(Reset_h),.sdram_wait(mem_init_sdram_wait),.sdram_ac(mem_init_sdram_ac),
.sdram_rd(mem_init_sdram_rd),.sdram_data(mem_init_sdram_data),.mem_data(mem_init_mem_data),
.sdram_addr(mem_init_sdram_addr),.mem_addr(mem_init_addr),.mem_init_done(mem_init_done),
.mem_wr(mem_init_wr),.mem_wr1(mem_init_wr1));

logic [127:0] Dnum_sdram_data;
logic Dnum_sdram_ac,Dnum_sdram_wr,Dnum_sdram_wait;
logic [21:0] Dnum_sdram_addr;
logic Dnum_busy,Dnum_done;
logic [15:0] Dnum_sdram_be;

Draw_score_combo Dnum(
.clk(MAX10_CLK1_50),.reset(Reset_h),.sdram_data(Dnum_sdram_data),.sdram_ac(Dnum_sdram_ac),
.sdram_wr(Dnum_sdram_wr),.sdram_wait(Dnum_sdram_wait),.sdram_addr(Dnum_sdram_addr),
.busy(Dnum_busy),.done(Dnum_done),.sdram_be(Dnum_sdram_be),.frame_flip(frame_flip),.score(score),.combo(combo),.precise(precise),
.new_frame(new_frame),.ram_wraddr(mem_init_addr),.ram_data(mem_init_mem_data),.ram_wr(mem_init_wr1));

logic [127:0] DS_sdram_data;
logic DS_sdram_ac,DS_sdram_wr,DS_sdram_wait;
logic [21:0] DS_sdram_addr;
logic DS_busy,DS_done;
logic [15:0] DS_be;
logic [12:0] score;
logic [3:0] combo;
logic [1:0] precise;

Draw_sprites sp(
.clk(MAX10_CLK1_50),.reset(Reset_h),.sdram_wait(DS_sdram_wait),.sdram_ac(DS_sdram_ac),
.sdram_wr(DS_sdram_wr),.sdram_data(DS_sdram_data),.ram_data(mem_init_mem_data),
.sdram_addr(DS_sdram_addr),.ram_wraddr(mem_init_addr[7:0]),
.new_frame(new_frame),.DFJK(DFJK),.frame_flip(frame_flip),.un_time(un_time),.busy(DS_busy),
.done(DS_done),.ram_wr(mem_init_wr),.score(score),.combo(combo),.precises(precise),.sdram_be(DS_be));


logic mem_init_sdram_wait,mem_init_sdram_ac,mem_init_sdram_rd,mem_init_wr,mem_init_wr1,mem_init_done;
logic [127:0]mem_init_sdram_data,mem_init_mem_data;
logic [21:0]mem_init_sdram_addr;
logic [9:0] mem_init_addr;

DrawDFJK_BK DFJK_BK(.new_frame(new_frame),.clk(MAX10_CLK1_50),.sdram_wait(DFJK_sdram_wait),.sdram_ac(DFJK_sdram_ac),
.reset(Reset_h),.frame_flip(frame_flip),.DFJK(DFJK),.sdram_rd(DFJK_sdram_rd),.sdram_wr(DFJK_sdram_wr),
.busy(DFJK_busy),.writedone(DFJK_sdram_writedone),.sdram_rddata(DFJK_sdram_rddata),.sdram_wrdata(DFJK_sdram_wrdata),
.sdram_addr(DFJK_sdram_addr));

logic DFJK_sdram_wait,DFJK_sdram_ac,DFJK_sdram_rd,DFJK_sdram_wr,DFJK_busy,DFJK_sdram_writedone;
logic [127:0]DFJK_sdram_rddata,DFJK_sdram_wrdata;
logic [21:0]DFJK_sdram_addr;

logic new_frame;

always_ff @(posedge pixel_clk)
begin
new_frame<=new_frame;

if (DrawY==523&&DrawX==760)
new_frame<=1;
else
new_frame<=0;
end


assign LEDR[0]=init_done;
assign LEDR[5]=init_error;

assign ARDUINO_IO[3] = aud_mclk_ctr[1];	 //generate 12.5MHz CODEC mclk
always_ff @(posedge MAX10_CLK1_50) begin
	aud_mclk_ctr <= aud_mclk_ctr + 1;
end

logic [1:0] aud_mclk_ctr;


I2S IIS
(
.LRClk(ARDUINO_IO[4]),.SClk(ARDUINO_IO[5]),.sdram_Wait(I2S_sdram_Wait), .sdram_ac(I2S_sdram_ac), 
.reset(Reset_h), .Clk50(MAX10_CLK1_50), .new_frame(new_frame), .sdram_rd(I2S_sdram_rd),
.sdram_data(I2S_sdram_data),
.busy(I2S_Busy),.Dout(Dout),.Write_done(I2S_Done),
.sdram_addr(I2S_sdram_addr),.*
);

logic I2S_sdram_Wait,I2S_sdram_ac,I2S_sdram_rd,I2S_Busy,I2S_Done;
logic [127:0] I2S_sdram_data;
logic[21:0] I2S_sdram_addr;
logic [127:0] tempdata1;
logic [7:0] wrusedw;
logic Dout,init_wait;

assign ARDUINO_IO[2]=Dout;
//assign ARDUINO_IO[2]=ARDUINO_IO[1];



lineb lb(.*,.clock(MAX10_CLK1_50),.sdram_data(lb_sdram_data),
		.sdram_addr(lb_sdram_addr),
		.sdram_ac(lb_sdram_ac),
		.sdram_rd(lb_sdram_rd),
		.busy(lb_Busy),
		.sdram_Wait(lb_sdram_Wait),.reset(Reset_h),.done(lb_done));

logic frame_flip,lb_sdram_Wait,lb_sdram_ac,lb_sdram_rd,lb_Busy,lb_done;
logic[127:0] lb_sdram_data;
logic[21:0] lb_sdram_addr;

universal_timer times(
.start_sign(start_sign),
//pause_sign,
.new_frame(new_frame),
.clk(MAX10_CLK1_50),
.reset(Reset_h),
.stop_sign(stop_sign),
.un_time(un_time)
);

logic start_sign,stop_sign;
logic [15:0]un_time;
endmodule
