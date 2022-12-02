

module sdcard_init (
	input  logic clk50,
	input  logic reset,          //starts as soon reset is deasserted
	output logic ram_we,         //RAM interface pins
	output logic [21:0] ram_address,
	output wire [127:0] ram_data,
	input  logic ram_op_begun,   //acknowledge from RAM to move to next word
	output logic ram_init_error, //error initializing
	output logic ram_init_done,  //done with reading all MAX_RAM_ADDRESS words
	output logic cs_bo, //SD card pins (also make sure to disable USB CS if using DE10-Lite)
	output logic sclk_o,
	output logic mosi_o,
	input  logic miso_i
);

parameter 			MAX_RAM_ADDRESS = 22'h31EFFFF;
parameter			SDHC 				 = 1'b1;

logic 				sd_read_block;
logic				sd_busy;
logic				sd_data_rdy;
logic				sd_data_next;
logic				sd_continue;
logic	[15:0]		sd_error;
logic [7:0] 		sd_output_data;
logic [31:0] 		sd_block_addr;

//registers written in 2-always method
enum logic [8:0]	{RESET, READBLOCK, READL_0, READL_1, READ0_0, READ0_1, READ1_0, 
READ1_1,READ2_0, READ2_1, READ3_0, READ3_1, READ4_0, READ4_1,READ5_0, READ5_1,READ6_0,
READ6_1,READ7_0, READ7_1,READ8_0, READ8_1,READ9_0, READ9_1,READ10_0, READ10_1,READ11_0, 
READ11_1,READ12_0, READ12_1,READ13_0, READ13_1,READH_0, READH_1, WRITE,WRITE1, ERROR, DONE} state_r, state_x;
logic [21:0]		ram_addr_r, ram_addr_x,ram_addr_r1, ram_addr_x1;  //word address for memory initialization
logic [127:0]		data_r, data_x;

//assign primary outputs to correct registers
assign ram_address = ram_addr_r;
assign ram_data = data_r; 

SdCardCtrl m_sdcard ( .clk_i(clk50),
							 .reset_i(reset),
							 .rd_i(sd_read_block),
							 .wr_i(1'b0), //never write
							 .continue_i(sd_continue), //FSM keeps track of address
							 .addr_i(sd_block_addr),
							 .data_i(), //never write
							 .data_o(sd_output_data),
							 .busy_o(sd_busy),
							 .hndShk_o(sd_data_rdy),
							 .hndShk_i(sd_data_next),		
							 .error_o(sd_error),
							 .cs_bo(cs_bo),
							 .sclk_o(sclk_o),
							 .mosi_o(mosi_o),
							 .miso_i(miso_i));
logic[3:0] flag;						 

initial
begin
ram_addr_r = 22'h3F0000;
end
always_ff @ (posedge clk50) 
begin
	if (reset) begin
		state_r <= RESET;
		ram_addr_r <= 22'h3F0000;
		ram_addr_r1 <= 22'h00;
		data_r <= 128'h0000;
	end
	else begin
		state_r <= state_x;
		data_r <= data_x;
		ram_addr_r <= ram_addr_x;
		ram_addr_r1 <= ram_addr_x1;
		end
end


always_comb 
begin
	//default combinational assignments
	sd_read_block = 1'b0;
	sd_continue = 1'b0;
	sd_data_next = 1'b0;
	ram_we = 1'b0;
	if (SDHC)//if SDHC mode, then this is block address (note that you need to change VHDL generic)
		sd_block_addr = (ram_addr_r1 >> 5) ;
	else
		sd_block_addr = (ram_addr_r1 << 4); //in SD mode, this is the *byte* address, change for SDHC 
	state_x = state_r;
	data_x = data_r;
	ram_addr_x = ram_addr_r;
	ram_addr_x1 = ram_addr_r1;
	ram_init_error = 1'b0;
	ram_init_done = 1'b0;

	unique case (state_r)
		RESET: begin //reset state, wait for SD initialization - if failed for any reason, go into ERROR state
			if ((sd_busy == 1'b0) && (sd_error == 16'h0000))
				state_x = READBLOCK;//properly initialized
			else if ((sd_busy == 1'b0) && (sd_error != 16'h0000))
				state_x = ERROR;
		end
		READBLOCK: begin //send enable to start block read
			if (ram_addr_r1 >= MAX_RAM_ADDRESS) //done with the whole range
				state_x = DONE;
			else begin
				sd_read_block = 1'b1; //start block read
				if (sd_block_addr != 32'h00000000)
					sd_continue = 1'b1;
				if (sd_busy == 1'b1)
					state_x = READH_0;
			end
		end
		READH_0: begin //read first byte (higher byte)
			if (sd_busy == 1'b0) //busy going low signals end of block, read next block
				state_x = READBLOCK;
			else if (sd_data_rdy == 1'b1) begin//still have more data in this block, read more bytes
				data_x[7:0] = sd_output_data;
				state_x = READH_1;
			end
		end
		READH_1: begin //ack first byte
			sd_data_next = 1'b1;
			if (sd_data_rdy == 1'b0)//moved on to next byte
				state_x = READ13_0;
		end
				READ13_0: begin //read second byte (lower byte)
			if (sd_data_rdy == 1'b1) begin
				data_x[15:8] = sd_output_data;
				state_x = READ13_1;
			end
		end
		READ13_1: begin //ack second byte
			sd_data_next = 1'b1;
			if (sd_data_rdy == 1'b0)//move on to next byte/write word
				state_x = READ12_0;
		end
				READ12_0: begin //read second byte (lower byte)
			if (sd_data_rdy == 1'b1) begin
				data_x[23:16] = sd_output_data;
				state_x = READ12_1;
			end
		end
		READ12_1: begin //ack second byte
			sd_data_next = 1'b1;
			if (sd_data_rdy == 1'b0)//move on to next byte/write word
				state_x = READ11_0;
		end
		READ11_0: begin //read second byte (lower byte)
			if (sd_data_rdy == 1'b1) begin
				data_x[31:24] = sd_output_data;
				state_x = READ11_1;
			end
		end
		READ11_1: begin //ack second byte
			sd_data_next = 1'b1;
			if (sd_data_rdy == 1'b0)//move on to next byte/write word
				state_x = READ10_0;
		end
		READ10_0: begin //read second byte (lower byte)
			if (sd_data_rdy == 1'b1) begin
				data_x[39:32] = sd_output_data;
				state_x = READ10_1;
			end
		end
		READ10_1: begin //ack second byte
			sd_data_next = 1'b1;
			if (sd_data_rdy == 1'b0)//move on to next byte/write word
				state_x = READ9_0;
		end
		
		READ9_0: begin //read second byte (lower byte)
			if (sd_data_rdy == 1'b1) begin
				data_x[47:40] = sd_output_data;
				state_x = READ9_1;
			end
		end
		READ9_1: begin //ack second byte
			sd_data_next = 1'b1;
			if (sd_data_rdy == 1'b0)//move on to next byte/write word
				state_x = READ8_0;
		end
		READ8_0: begin //read first byte (higher byte)
			if (sd_data_rdy == 1'b1) begin//still have more data in this block, read more bytes
				data_x[55:48] = sd_output_data;
				state_x = READ8_1;
			end
		end
		READ8_1: begin //ack first byte
			sd_data_next = 1'b1;
			if (sd_data_rdy == 1'b0)//moved on to next byte
				state_x = READ7_0;
		end
		READ7_0: begin //read second byte (lower byte)
			if (sd_data_rdy == 1'b1) begin
				data_x[63:56] = sd_output_data;
				state_x = READ7_1;
			end
		end
		READ7_1: begin //ack second byte
			sd_data_next = 1'b1;
			if (sd_data_rdy == 1'b0)//move on to next byte/write word
				state_x = READ6_0;
		end
		READ6_0: begin //read first byte (higher byte)
			if (sd_data_rdy == 1'b1) begin//still have more data in this block, read more bytes
				data_x[71:64] = sd_output_data;
				state_x = READ6_1;
			end
		end
		
		READ6_1: begin //ack first byte
			sd_data_next = 1'b1;
			if (sd_data_rdy == 1'b0)//moved on to next byte
				state_x = READ5_0;
		end
		
		READ5_0: begin //read second byte (lower byte)
			if (sd_data_rdy == 1'b1) begin
				data_x[79:72] = sd_output_data;
				state_x = READ5_1;
			end
		end
		READ5_1: begin //ack second byte
			sd_data_next = 1'b1;
			if (sd_data_rdy == 1'b0)//move on to next byte/write word
				state_x = READ4_0;
		end
		READ4_0: begin //read second byte (lower byte)
			if (sd_data_rdy == 1'b1) begin
				data_x[87:80] = sd_output_data;
				state_x = READ4_1;
			end
		end
		READ4_1: begin //ack second byte
			sd_data_next = 1'b1;
			if (sd_data_rdy == 1'b0)//move on to next byte/write word
				state_x = READ3_0;
		end
		
		READ3_0: begin //read second byte (lower byte)
			if (sd_data_rdy == 1'b1) begin
				data_x[95:88] = sd_output_data;
				state_x = READ3_1;
			end
		end
		READ3_1: begin //ack second byte
			sd_data_next = 1'b1;
			if (sd_data_rdy == 1'b0)//move on to next byte/write word
				state_x = READ2_0;
		end
		READ2_0: begin //read first byte (higher byte)
			if (sd_data_rdy == 1'b1) begin//still have more data in this block, read more bytes
				data_x[103:96] = sd_output_data;
				state_x = READ2_1;
			end
		end
		READ2_1: begin //ack first byte
			sd_data_next = 1'b1;
			if (sd_data_rdy == 1'b0)//moved on to next byte
				state_x = READ1_0;
		end
		READ1_0: begin //read second byte (lower byte)
			if (sd_data_rdy == 1'b1) begin
				data_x[111:104] = sd_output_data;
				state_x = READ1_1;
			end
		end
		READ1_1: begin //ack second byte
			sd_data_next = 1'b1;
			if (sd_data_rdy == 1'b0)//move on to next byte/write word
				state_x = READ0_0;
		end
		READ0_0: begin //read first byte (higher byte)
			if (sd_data_rdy == 1'b1) begin//still have more data in this block, read more bytes
				data_x[119:112] = sd_output_data;
				state_x = READ0_1;
			end
		end
		READ0_1: begin //ack first byte
			sd_data_next = 1'b1;
			if (sd_data_rdy == 1'b0)//moved on to next byte
				state_x = READL_0;
		end
		READL_0: begin //read second byte (lower byte)
			if (sd_data_rdy == 1'b1) begin
				data_x[127:120] = sd_output_data;
				state_x = READL_1;
			end
		end
		READL_1: begin //ack second byte
			sd_data_next = 1'b1;
			if (sd_data_rdy == 1'b0)//move on to next byte/write word
				state_x = WRITE;
		end
		
		WRITE:
		begin
			ram_we = 1'b1;
			if (ram_op_begun == 1'b1) begin//RAM as responded
				ram_addr_x = ram_addr_r + 1;
				ram_addr_x1 = ram_addr_r1 + 1;
				state_x = READH_0;
			end
		end
		ERROR: begin
			ram_init_error = 1'b1;
		end
		DONE: begin
			ram_init_done = 1'b1;
		end
	endcase 
end //end comb
	
endmodule

