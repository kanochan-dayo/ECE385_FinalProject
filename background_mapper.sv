module lineb (
		input [9:0] DrawX,     
						DrawY,
		input [16:0] sdram_data,
		output [24:0]sdram_addr,
		input sdram_ac,
		output sdram_rd,
		output busy,
		input clock,
		blank,
		reset,
		new_frame,
		sdram_Wait,
		output frame_flip,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B
);



 background_palette_rom er(.address(pixel_palette_index), .data_Out(RGB_ALL));
 line_buffer line_buf(.rdaddress(place_a),.clock(clock),.q(pixel_palette_a),.wraddress(place_b),.data(pixel_palette_b),.*);
 logic [23:0] RGB_ALL;
 logic [9:0] place_a,place_b,WriteY,WriteX,WriteX_x;
 logic [7:0] pixel_palette_index;
 logic [15:0] pixel_palette_a,pixel_palette_b;
 logic number,flip,frame_flip,wren;
 
 parameter [19:0]Address1=20'h9CD20;
 parameter [19:0]Address2=20'hC2520;
 
 enum logic[2:0] {Halted,Read,Read1,Read2,Pause,Pause1,Pauserr} State,Next_state;
 
 always_ff @(posedge clock)
 begin
 if(reset)
 begin
 WriteX<=0;
 State<=Halted;
 end
 else
 begin
 State<=Next_state;
 WriteX<=WriteX_x;
 end
 end
 
  always_ff @(posedge new_frame)
 begin
	frame_flip<=frame_flip+1;
 end

 
 always_comb
begin
 Next_state=State;
 case(State)
 Halted:
 if (new_frame)
 Next_state=Read;
 Read:
 if (sdram_ac)
 Next_state=Read1;
 Read1:
 begin
 if(WriteX==639)
 Next_state=Pauserr;
 else if(~sdram_ac)
 Next_state=Read2;
 end
 Read2:
 Next_state=Read;
 Pauserr:
 Next_state=Pause;
 Pause:
 if(DrawY==478)
 Next_state=Halted;
 else if(DrawX==799)
 Next_state=Read;
 
 endcase
end 


always_comb
begin
sdram_rd=0;
busy=0;
wren=0;
case(State)
 Halted:
 ;
 Read:
 begin
 busy=1;
 sdram_rd=1
 end
 Read1:
 begin
 WriteX_x=Write_x+2
 wren=1;
 busy=1;
 end
 Pauserr:
 
 

end

always_comb
begin
WriteY=DrawY==524?0:DrawY+1;
if(frame_flip)
sdram_addr=WriteX[9:1]+(WriteY*320)+Address1;
else
sdram_addr=WriteX[9:1]+(WriteY*320)+Address2;

	flip=WriteY[0];
	place_a[8:0] = DrawX[9:1];
	place_a[9]=flip;
	place_b[9]=~flip;
	number=DrawX[0];
	case (number)
	1'b0:
	pixel_palette_index=pixel_palette_b[15:8];
	1'b1:
	pixel_palette_index=pixel_palette_b[7:0];
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