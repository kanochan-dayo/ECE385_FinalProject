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
	logic [3:0] DFJK;
	logic [9:0] LEDRR;
	logic SD_CS;
	assign LEDR[9:6]=LEDRR[9:6];
	assign LEDR[2:1]={rdempty,wrfull};

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
		
	HexDriver hex_driver5 (ar_addr[23:20], HEX5[6:0]);
	assign HEX5[7] = 1'b1;
	
	HexDriver hex_driver4 (ar_addr[19:16], HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (ar_wrdata[15:12], HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver2 ({1'b0,wrusedw[10:8]}, HEX2[6:0]);
	assign HEX2[7] = 1'b1;
	
	HexDriver hex_driver1 (wrusedw[7:4], HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (wrusedw[3:0], HEX0[6:0]);
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
		
		//VGA
//		.vga_port_red (VGA_R),
//		.vga_port_green (VGA_G),
//		.vga_port_blue (VGA_B),
//		.vga_port_hs (VGA_HS),
//		.vga_port_vs (VGA_VS)

		// DFJK
		.key_dfjk_export(DFJK),
		
		//init bridge
//		.init_out_acknowledge(init_ac),           //                init_out.acknowledge
//		.init_out_irq(0),                   //                        .irq
//		.init_out_address(init_addr),               //                        .address
//		.init_out_bus_enable(init_bus),            //                        .bus_enable
//		.init_out_byte_enable(init_be),           //                        .byte_enable
//		.init_out_rw(init_rw),                    //                        .rw
//		.init_out_write_data(init_data),            //                        .write_data
//		.init_out_read_data(0)             //                        .read_data
		
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
		.bridge_address({ar_addr,1'b0}),     //     bridge.address
		.bridge_byte_enable(ar_be), //           .byte_enable
		.bridge_read(ar_read),        //           .read
		.bridge_write(ar_write),       //           .write
		.bridge_write_data(ar_wrdata),  //           .write_data
		.bridge_acknowledge(ar_ac), //           .acknowledge
		.bridge_read_data(ar_rddata),   //           .read_data
		.clk_clk(MAX10_CLK1_50),            //        clk.clk
		.reset_reset_n(KEY[0])
		);

logic [24:0] ar_addr,init_addr;
logic [1:0] ar_be,init_be;
logic ar_read,ar_write,ar_ac;
logic [15:0] ar_wrdata,ar_rddata,init_data;
logic init_we,init_ac,init_done,init_cs_bo,init_sclk_o,init_mosi_o,init_miso_i,init_error;
logic [15:0] init_wrdata;
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

logic new_frame;

always_ff @(posedge pixel_clk)
begin
new_frame<=new_frame;

if (DrawY==524)
new_frame<=1;
else if(DrawY==0)
new_frame<=0;
end


assign LEDR[0]=init_done;
assign LEDR[5]=init_error;

assign ARDUINO_IO[3] = aud_mclk_ctr[1];	 //generate 12.5MHz CODEC mclk
always_ff @(posedge MAX10_CLK2_50) begin
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

logic I2S_sdram_Wait,I2S_sdram_ac,I2S_sdram_rd,I2S_Busy,I2S_Done,rdempty,wrfull;
logic[15:0] I2S_sdram_data;
logic[24:0] I2S_sdram_addr;
logic [10:0] wrusedw;
logic Dout;

assign ARDUINO_IO[2]=Dout;

endmodule
