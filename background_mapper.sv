module background_mapper (
		input [9:0] DrawX,     
						DrawY,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,
);
<<<<<<< Updated upstream

=======
 background_palette_rom er(.address(pixel_palette_index));
 background_pixel_rom yi(.address(place));
 logic [63:0] place
 logic [7:0] pixel_palette_index
always_comb
begin
 if (DrawX <= 639) && (Draw <= 479){
	place = (DrawX + DrawY * 640)>>3;
	
}
end
>>>>>>> Stashed changes



endmodule