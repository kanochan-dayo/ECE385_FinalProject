/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  background_palette_rom
(
		input [7:0] address,
		output logic [23:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
parameter [0:255][23:0] mem ;

initial
begin
	 $readmemh("sprite_bytes/256palette_rom.txt", mem);
end



assign	data_Out<= mem[read_address];


endmodule
