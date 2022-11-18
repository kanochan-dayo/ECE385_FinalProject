module background_mapper (
		input [9:0] DrawX,     
						DrawY,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,
);



 background_palette_rom er(.address(pixel_palette_index), .data_Out(RGB_ALL));
 background_pixel_rom yi(.address(place),.data_Out( pixel_palette));
 logic [23:0] RGB_ALL;
 logic [15:0] place;
 logic [7:0] pixel_palette_index;
 logic [63:0] pixel_palette;
always_comb
begin
 if (DrawX <= 639) && (Draw <= 479){
	place = (DrawX + DrawY * 640)>>3;
	number=DrawX[2:0];
	case (number)
	3'b0:
	pixel_palette_index=pixel_palette[63:56];
	3'b1:
	pixel_palette_index=pixel_palette[55:48];
	3'b10:
	pixel_palette_index=pixel_palette[47:40];
	3'b11:
	pixel_palette_index=pixel_palette[39:32];
	3'b100:
	pixel_palette_index=pixel_palette[31:24];
	3'b101:
	pixel_palette_index=pixel_palette[23:16];
	3'b110:
	pixel_palette_index=pixel_palette[15:8];
	3'b111:
	pixel_palette_index=pixel_palette[7:0];
	endcase
	VGA_R=RGB_ALL[23:20];
	VGA_G=RGB_ALL[15:12];
	VGA_B=RGB_ALL[7:4];
}
end




endmodule