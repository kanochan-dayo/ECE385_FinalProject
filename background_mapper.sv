module background_mapper (
		input [9:0] DrawX,     
						DrawY,
		input clock,
		blank,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B
);



 background_palette_rom er(.address(pixel_palette_index), .data_Out(RGB_ALL));
 background_pixel_rom yi(.address_a(place_a),.q_a(pixel_palette_a),.address_b(place_b),.q_b(pixel_palette_b),.*);
 logic [23:0] RGB_ALL;
 logic [13:0] place_a,place_b;
 logic [7:0] pixel_palette_index;
 logic [63:0] pixel_palette_a,pixel_palette_b;
 logic [2:0] number;
always_comb
begin

	place_a <= (DrawX>>4) + ((DrawY>>1) * 40);
	place_b <= ((DrawX+8)>>4) + ((DrawY>>1) * 40);
	number=DrawX[3:1];
	case (number)
	3'b0:
	pixel_palette_index=pixel_palette_b[63:56];
	3'b1:
	pixel_palette_index=pixel_palette_b[55:48];
	3'b10:
	pixel_palette_index=pixel_palette_b[47:40];
	3'b11:
	pixel_palette_index=pixel_palette_b[39:32];
	3'b100:
	pixel_palette_index=pixel_palette_a[31:24];
	3'b101:
	pixel_palette_index=pixel_palette_a[23:16];
	3'b110:
	pixel_palette_index=pixel_palette_a[15:8];
	3'b111:
	pixel_palette_index=pixel_palette_a[7:0];
	endcase
if (blank)
 begin
	VGA_R<=RGB_ALL[23:20];
	VGA_G<=RGB_ALL[15:12];
	VGA_B<=RGB_ALL[7:4];
end
else
 begin
	VGA_R=0;
	VGA_G=0;
	VGA_B=0;
end
end


endmodule