module lineb (
		input [9:0] DrawX,     
						DrawY,
		input [128:0] sdram_data,
		output [21:0]sdram_addr,
		input sdram_ac,
		output sdram_rd,
		output busy,done,
		input clock,
		blank,
		reset,
		new_frame,
		sdram_Wait,
		stop_sign,
		start_sign,
		output frame_flip,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B
);



 background_palette_rom er(.address(pixel_palette_index), .data_Out(RGB_ALL));
 
 line_buffer line_buf(.rdaddress(place_a),.clock(~clock),.q(pixel_palette_b),
 .wraddress(place_b),.data(sdram_data),.wren(wren),.*);
 
 logic [23:0] RGB_ALL;
 logic [6:0] place_a,place_b;
 logic [9:0]WriteY,WriteX,WriteX_x;
 logic [7:0] pixel_palette_index;
 logic [127:0] pixel_palette_a,pixel_palette_b;
 logic flip,wren;
 logic [3:0] number;
 
 always_ff @ (negedge DrawX[3])
 begin
 pixel_palette_a<=pixel_palette_b;
 end
 
 parameter [21:0]Address1=22'h100000;
 parameter [21:0]Address2=22'h200000;
 
 parameter [0:29] [21:0] Startscreen_addr={
	22'h104B00,22'h109600,22'h10E100,22'h112C00,22'h117700,22'h11C200,
	22'h120D00,22'h125800,22'h12A300,22'h12EE00,22'h133900,22'h138400,
	22'h13CF00,22'h141A00,22'h146500,22'h14B000,22'h14FB00,22'h154600,
	22'h159100,22'h15DC00,22'h162700,22'h167200,22'h16BD00,22'h170800,
	22'h175300,22'h179E00,22'h17E900,22'h183400,22'h187F00,22'h18CA00};

logic[4:0] Startscreen_index;
always_ff @(posedge new_frame)
begin
if (reset)
	begin
		Startscreen_index<=0;
	end
else if(Startscreen_index==29)
	begin
		Startscreen_index<=Startscreen_index;
	end
else if(start_sign)
Startscreen_index<=Startscreen_index+1;
else
Startscreen_index<=Startscreen_index;
end

//  parameter [4:0] [21:0] Endscreen_data;
 
 enum logic[2:0] {Halted,Read,Read1,Pause,Pause1,Done} State,Next_state;
 
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
 if (~sdram_Wait)
 Next_state=Read;
 
 Read:
 if (sdram_ac)
 Next_state=Read1;
 
 Read1:
 begin
 if(WriteX==624)
 Next_state=Pause;
 else
 Next_state=Read;
 end
 
 Pause:
 if(DrawY==479)
 Next_state=Done;
 else if(DrawX==760)
 Next_state=Pause1;
 
 Pause1:
 if(DrawX==0)
 Next_state=Read;
 
 Done:
 if(new_frame)
 Next_state=Halted;
 
 endcase
end 


always_comb
begin
done=0;
sdram_rd=0;
busy=0;
wren=0;
WriteX_x=WriteX;
case(State)
 Halted:
 begin
 busy=1;
 WriteX_x=0;
 end
 Read:
 begin
 busy=1;
 sdram_rd=1;
 end
 Read1:
 begin
 wren=1;
 WriteX_x=WriteX+16;
 busy=1;
 end
 
Pause:
WriteX_x=0;
Pause1:
begin
WriteX_x=0;
busy=1;
end
Done:
done=1;

endcase
end

always_comb
begin
WriteY=(DrawY==524)?0:DrawY+1;
if(Startscreen_index==29)
	begin
		if(frame_flip)
			sdram_addr=WriteX[9:4]+(WriteY*40)+Address1;
		else
			sdram_addr=WriteX[9:4]+(WriteY*40)+Address2;
	end
else 
	begin
		sdram_addr=Startscreen_addr[Startscreen_index]+WriteX[9:4]+(WriteY*40);
	end
	
flip=WriteY[0];
place_a[5:0] = (DrawX[9:4]<=41)?DrawX[9:4]+1:0;
place_a[6]=DrawX[9:4]<=41?flip:~flip;
place_b[6]=~flip;
place_b[5:0] = WriteX[9:4];
number=DrawX[3:0];
	case (number)
	4'h0:
	pixel_palette_index=pixel_palette_a[7:0];
	4'h1:
	pixel_palette_index=pixel_palette_a[15:8];
	4'h2:
	pixel_palette_index=pixel_palette_a[23:16];
	4'h3:
	pixel_palette_index=pixel_palette_a[31:24];
	4'h4:
	pixel_palette_index=pixel_palette_a[39:32];
	4'h5:
	pixel_palette_index=pixel_palette_a[47:40];
	4'h6:
	pixel_palette_index=pixel_palette_a[55:48];
	4'h7:
	pixel_palette_index=pixel_palette_a[63:56];
	4'h8:
	pixel_palette_index=pixel_palette_a[71:64];
	4'h9:
	pixel_palette_index=pixel_palette_a[79:72];
	4'hA:
	pixel_palette_index=pixel_palette_a[87:80];
	4'hB:
	pixel_palette_index=pixel_palette_a[95:88];
	4'hC:
	pixel_palette_index=pixel_palette_a[103:96];
	4'hD:
	pixel_palette_index=pixel_palette_a[111:104];
	4'hE:
	pixel_palette_index=pixel_palette_a[119:112];
	4'hF:
	pixel_palette_index=pixel_palette_a[127:120];
	endcase
if (blank&&(~stop_sign))
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