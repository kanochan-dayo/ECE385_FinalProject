module Draw_sprites(
input clk,reset,sdram_wait,sdram_ac,ram_wr,new_frame,frame_flip,d_changed,f_changed,j_changed,k_changed,
input [15:0] un_time,
input [3:0]DFJK,
input [7:0] ram_wraddr,
input [127:0]ram_data,
output [127:0]sdram_data,
output [21:0]sdram_addr,
output sdram_wr,busy,done,
output [12:0] score,
output [3:0] combo,
output [1:0] precises,
output [15:0] sdram_be
);
always_comb
begin
	if(frame_flip)
	begin
		if(sdram_addr-wraddr_offset1>=(356+17)*40)
			sdram_be=0;
		else
			sdram_be=16'hFFFF;
	end
else
begin

		if(sdram_addr-wraddr_offset0>=(356+17)*40)
			sdram_be=0;
		else
			sdram_be=16'hFFFF;

end
end

logic [15:0] precise_flash_time;
always_ff @ (posedge new_frame)
begin
if (precise!=0)
begin
precises<=precise;
precise_flash_time<=un_time;
end
else if(un_time-precise_flash_time>30)
begin
precise_flash_time<=un_time;
precises<=0;
end
else
begin
precise_flash_time<=precise_flash_time;
precises<=precises;
end
end

logic [1:0] precise;
always_comb
begin
if(precise_d_x==2'b11||precise_f_x==2'b11||precise_j_x==2'b11||precise_k_x==2'b11)
precise=2'b11;
else if(precise_d_x==2'b10||precise_f_x==2'b10||precise_j_x==2'b10||precise_k_x==2'b10)
precise=2'b10;
else if(precise_d_x==2'b01||precise_f_x==2'b01||precise_j_x==2'b01||precise_k_x==2'b01)
precise=2'b01;
else
precise=2'b00;
end

logic [10:0] score_d,score_f,score_j,score_k;
logic  combo_d,combo_f,combo_j,combo_k;
always_comb
begin
    if(precise[1]==1||precise==2'b00)
    combo=4'h0;
    else
    combo=combo_d+combo_f+combo_j+combo_k;

    case(precise_d_x)
    2'b01:combo_d=1;
    default:combo_d=0;
    endcase
    case(precise_f_x)
    2'b01:combo_f=1;
    default:combo_f=0;
    endcase
    case(precise_j_x)
    2'b01:combo_j=1;
    default:combo_j=0;
    endcase
    case(precise_k_x)
    2'b01:combo_k=1;
    default:combo_k=0;
    endcase
    score=score_d+score_f+score_j+score_k;
    case(precise_d_x)
    2'b00:score_d=0;
    2'b10:score_d=950;
    2'b01:score_d=1900;
    2'b11:score_d=0;
    endcase
    case(precise_f_x)
    2'b00:score_f=0;
    2'b10:score_f=950;
    2'b01:score_f=1900;
    2'b11:score_f=0;
    endcase
    case(precise_j_x)
    2'b00:score_j=0;
    2'b10:score_j=950;
    2'b01:score_j=1900;
    2'b11:score_j=0;
    endcase
    case(precise_k_x)
    2'b00:score_k=0;
    2'b10:score_k=950;
    2'b01:score_k=1900;
    2'b11:score_k=0;
    endcase
end





key_d d(.addr(d_addr), 
.key_1(d0_key), 
.key_2(d1_key), 
.key_3(d2_key), 
.key_4(d3_key));
key_f f(.addr(f_addr),
.key_1(f0_key),
.key_2(f1_key),
.key_3(f2_key),
.key_4(f3_key));
key_j j(.addr(j_addr),
.key_1(j0_key),
.key_2(j1_key),
.key_3(j2_key),
.key_4(j3_key));
key_k k(.addr(k_addr),
.key_1(k0_key),
.key_2(k1_key),
.key_3(k2_key),
.key_4(k3_key));

logic [7:0] d_addr,f_addr,j_addr,k_addr;
logic [7:0] d_addr_x,f_addr_x,j_addr_x,k_addr_x;

logic [15:0] d0_key,d1_key,d2_key,d3_key,f0_key,f1_key,f2_key,f3_key,j0_key,j1_key,j2_key,j3_key,k0_key,k1_key,k2_key,k3_key;

logic [1:0] precise_d_x,precise_f_x,precise_j_x,precise_k_x;

logic [1:0] Key_type[15:0];
assign Key_type[0]=d0_key[15:14];
assign Key_type[1]=d1_key[15:14];
assign Key_type[2]=d2_key[15:14];
assign Key_type[3]=d3_key[15:14];
assign Key_type[4]=f0_key[15:14];
assign Key_type[5]=f1_key[15:14];
assign Key_type[6]=f2_key[15:14];
assign Key_type[7]=f3_key[15:14];
assign Key_type[8]=j0_key[15:14];
assign Key_type[9]=j1_key[15:14];
assign Key_type[10]=j2_key[15:14];
assign Key_type[11]=j3_key[15:14];
assign Key_type[12]=k0_key[15:14];
assign Key_type[13]=k1_key[15:14];
assign Key_type[14]=k2_key[15:14];
assign Key_type[15]=k3_key[15:14];

assign DFJK_valid[0]=vaild_temp[0]>=0;
assign DFJK_valid[1]=vaild_temp[1]>=0;
assign DFJK_valid[2]=vaild_temp[2]>=0;
assign DFJK_valid[3]=vaild_temp[3]>=0;
assign DFJK_valid[4]=vaild_temp[4]>=0;
assign DFJK_valid[5]=vaild_temp[5]>=0;
assign DFJK_valid[6]=vaild_temp[6]>=0;
assign DFJK_valid[7]=vaild_temp[7]>=0;
assign DFJK_valid[8]=vaild_temp[8]>=0;
assign DFJK_valid[9]=vaild_temp[9]>=0;
assign DFJK_valid[10]=vaild_temp[10]>=0;
assign DFJK_valid[11]=vaild_temp[11]>=0;
assign DFJK_valid[12]=vaild_temp[12]>=0;
assign DFJK_valid[13]=vaild_temp[13]>=0;
assign DFJK_valid[14]=vaild_temp[14]>=0;
assign DFJK_valid[15]=vaild_temp[15]>=0;



int vaild_temp[15:0];
assign vaild_temp[0]=-mv_speed*(d0_key[13:0]-un_time)+offset_y;
assign vaild_temp[1]=-mv_speed*(d1_key[13:0]-un_time)+offset_y;
assign vaild_temp[2]=-mv_speed*(d2_key[13:0]-un_time)+offset_y;
assign vaild_temp[3]=-mv_speed*(d3_key[13:0]-un_time)+offset_y;
assign vaild_temp[4]=-mv_speed*(f0_key[13:0]-un_time)+offset_y;
assign vaild_temp[5]=-mv_speed*(f1_key[13:0]-un_time)+offset_y;
assign vaild_temp[6]=-mv_speed*(f2_key[13:0]-un_time)+offset_y;
assign vaild_temp[7]=-mv_speed*(f3_key[13:0]-un_time)+offset_y;
assign vaild_temp[8]=-mv_speed*(j0_key[13:0]-un_time)+offset_y;
assign vaild_temp[9]=-mv_speed*(j1_key[13:0]-un_time)+offset_y;
assign vaild_temp[10]=-mv_speed*(j2_key[13:0]-un_time)+offset_y;
assign vaild_temp[11]=-mv_speed*(j3_key[13:0]-un_time)+offset_y;
assign vaild_temp[12]=-mv_speed*(k0_key[13:0]-un_time)+offset_y;
assign vaild_temp[13]=-mv_speed*(k1_key[13:0]-un_time)+offset_y;
assign vaild_temp[14]=-mv_speed*(k2_key[13:0]-un_time)+offset_y;
assign vaild_temp[15]=-mv_speed*(k3_key[13:0]-un_time)+offset_y;








logic d_next,f_next,j_next,k_next;


always_ff @(posedge new_frame or posedge reset)
 begin 
    if(reset)
	 begin
        d_addr<=0;
        f_addr<=0;
        j_addr<=0;
        k_addr<=0;
    end
	     else
    begin
        d_addr<=d_addr_x;
        f_addr<=f_addr_x;
        j_addr<=j_addr_x;
        k_addr<=k_addr_x;
    end
end



always_comb 
begin
    d_next=precise_d_x[0]|precise_d_x[1];
    f_next=precise_f_x[0]|precise_f_x[1];
    j_next=precise_j_x[0]|precise_j_x[1];
    k_next=precise_k_x[0]|precise_k_x[1];
    if(d0_key[13:0]==un_time) 
        precise_d_x=2'b11;
    else if(d_changed==0&&d0_key[15:14]==2'b10 &&DFJK[3]==0)
        precise_d_x=2'b11;
    else if(d_changed==0)
        precise_d_x=2'b00;
    else
    begin
        if(d0_key[15:14]==2'b10)
        begin
             precise_d_x=2'b01;
        end
        else if(DFJK[3]==0)
            precise_d_x=2'b00;

        else if(d0_key[13:0]-un_time>26)
            precise_d_x=2'b00;
        else if(d0_key[13:0]-un_time>22)
            precise_d_x=2'b11;
        else if(d0_key[13:0]-un_time>18)
            precise_d_x=2'b10;
        else
            precise_d_x=2'b01;
    end

    if(f0_key[13:0]==un_time) 
        precise_f_x=2'b11;
    else if(f_changed==0&&f0_key[15:14]==2'b10 &&DFJK[2]==0)
        precise_f_x=2'b11;
    else if(f_changed==0)
        precise_f_x=2'b00;
    else
    begin
        if(f0_key[15:14]==2'b10)
        begin
             precise_f_x=2'b01;
        end
        else if(DFJK[2]==0)
            precise_f_x=2'b00;

        else if(f0_key[13:0]-un_time>26)
            precise_f_x=2'b00;
        else if(f0_key[13:0]-un_time>22)
            precise_f_x=2'b11;
        else if(f0_key[13:0]-un_time>18)
            precise_f_x=2'b10;
        else
            precise_f_x=2'b01;
    end

    if(j0_key[13:0]==un_time) 
        precise_j_x=2'b11;
    else if(j_changed==0&&j0_key[15:14]==2'b10 &&DFJK[1]==0)
        precise_j_x=2'b11;
    else if(j_changed==0)
        precise_j_x=2'b00;
    else
    begin
        if(j0_key[15:14]==2'b10)
        begin
            precise_j_x=2'b01;
        end
        else if(DFJK[1]==0)
            precise_j_x=2'b00;

        else if(j0_key[13:0]-un_time>26)
            precise_j_x=2'b00;
        else if(j0_key[13:0]-un_time>22)
            precise_j_x=2'b11;
        else if(j0_key[13:0]-un_time>18)
            precise_j_x=2'b10;
        else
            precise_j_x=2'b01;
    end

    if(k0_key[13:0]==un_time) 
        precise_k_x=2'b11;
    else if(k_changed==0&&k0_key[15:14]==2'b10 &&DFJK[0]==0)
        precise_k_x=2'b11;
    else if(k_changed==0)
        precise_k_x=2'b00;
    else
    begin
        if(k0_key[15:14]==2'b10)
        begin
				precise_k_x=2'b01;
        end
        else if(DFJK[0]==0)
            precise_k_x=2'b00;

        else if(k0_key[13:0]-un_time>26)
            precise_k_x=2'b00;
        else if(k0_key[13:0]-un_time>22)
            precise_k_x=2'b11;
        else if(k0_key[13:0]-un_time>18)
            precise_k_x=2'b10;
        else
            precise_k_x=2'b01;
    end
end

always_comb 
begin
    d_addr_x=d_addr;
    f_addr_x=f_addr;
    j_addr_x=j_addr;
    k_addr_x=k_addr;
    if(d_next==1)
    begin
        d_addr_x=d_addr+1;
    end
    if(f_next==1)
    begin
        f_addr_x=f_addr+1;
    end
    if(j_next==1)
    begin
        j_addr_x=j_addr+1;
    end
    if(k_next==1)
    begin
        k_addr_x=k_addr+1;
    end
end



logic [127:0] d_data,f_data,j_data,k_data,ram_data_out;
logic [3:0] DFJK4321,DFJK4321_x;
logic [8:0] ram_rdaddr;
logic [21:0] sdram_addr_x;
parameter wraddr_key_shift_offset=22'h25;
parameter mv_speed=14;
parameter d_k_ram_offset=0;
parameter f_j_ram_offset=36;
parameter offset_y=356+7*mv_speed;
parameter wraddr_offset0=22'h100000;
parameter wraddr_offset1=22'h200000;
parameter d_track_offset=22'h1;
parameter f_track_offset=22'h4;
parameter j_track_offset=22'h7;
parameter k_track_offset=22'ha;


int Pos_X,Pos_Y;
int Dist_X,Dist_Y;

always_comb
begin
    Pos_X=-1;
    Pos_Y=-1;
    Dist_X=0;
    Dist_Y=0;
        Pos_Y=vaild_temp[DFJK4321];
        case(DFJK4321)
            4'b0000:
            begin
                Pos_X=16;
                Dist_X=48;
                Dist_Y=12;
            end
            4'b0001:
            begin
                Pos_X=16;
                Dist_X=48;
                Dist_Y=12;

            end
            4'b0010:
            begin
                Pos_X=16;
                Dist_X=48;
                Dist_Y=12;

            end
            4'b0011:
            begin
                Pos_X=16;
                Dist_X=48;
                Dist_Y=12;

            end
            4'b0100:
            begin
                Pos_X=64;
                Dist_X=48;
                Dist_Y=12;

            end
            4'b0101:
            begin
                Pos_X=64;
                Dist_X=48;
                Dist_Y=12;
            end
            4'b0110:
            begin
                Pos_X=64;
                Dist_X=48;
                Dist_Y=12;
            end
            4'b0111:
            begin
                Pos_X=64;
                Dist_X=48;
                Dist_Y=12;
            end
            4'b1000:
            begin
                Pos_X=112;
                Dist_X=48;
                Dist_Y=12;
            end
            4'b1001:
            begin
                Pos_X=112;
                Dist_X=48;
                Dist_Y=12;
            end
            4'b1010:
            begin
                Pos_X=112;
                Dist_X=48;
                Dist_Y=12;
            end
            4'b1011:
            begin
                Pos_X=112;
                Dist_X=48;
                Dist_Y=12;
            end
            4'b1100:
            begin
                Pos_X=160;
                Dist_X=48;
                Dist_Y=12;
            end
            4'b1101:
            begin
                Pos_X=160;
                Dist_X=48;
                Dist_Y=12;
            end
            4'b1110:
            begin
                Pos_X=160;
                Dist_X=48;
                Dist_Y=12;
            end
            4'b1111:
            begin
                Pos_X=160;
                Dist_X=48;
                Dist_Y=12;
            end
        endcase

end



enum logic [3:0]{Halted,Read,Read1,Write,Write1,Examine,Examinelong,
Readlong,Writelong,Writelong1,To_next,Pause,Pauselong,Done} State,Next_state;

Sprite_ram ram(
	.clock(clk),
	.data(ram_data),
	.rdaddress(ram_rdaddr),
	.wraddress(ram_wraddr),
	.wren(ram_wr),
	.q(ram_data_out));


always_ff @(posedge clk)
begin
    if(reset)
    begin
        DFJK4321<=4'b0000;
        State<=Halted;
        ram_rdaddr<=0;
        sdram_addr<=0;
    end
    else
    begin
        State<=Next_state;
        DFJK4321<=DFJK4321_x;
        ram_rdaddr<=ram_rdaddr_x;
        sdram_addr<=sdram_addr_x;
    end
end

logic rd_req,is_long;
logic [21:0] sdram_addr_max;
logic [7:0]ram_rdaddr_x;
logic [15:0] DFJK_valid;

parameter Red_long=128'hC5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5;
parameter Blue_long=128'h53535353535353535353535353535353;

always_ff @(posedge rd_req or posedge reset)
begin
    if(reset)
        sdram_data<=0;
    else if(~is_long)
        sdram_data<=ram_data_out;
    else
    if(DFJK4321[3]!=DFJK4321[2])
        sdram_data<=Red_long;
    else
        sdram_data<=Blue_long;
end



always_comb
begin
    Next_state=State;
    case(State)
    Halted:
    if(~sdram_wait)
    begin
        if(Key_type[DFJK4321]==2'b10)
        Next_state=Examinelong;
        else
        Next_state=Examine;
    end
    Examinelong:
    begin
	 if(sdram_addr_max<=sdram_addr_x)
	 Next_state=To_next;
	 else
	 begin
        if(DFJK4321[1:0]==2'b00)
        Next_state=Readlong;
        else 
        begin
            if(DFJK_valid[DFJK4321-1])
            Next_state=Readlong;
            else
            Next_state=To_next;
        end
		end
    end
    Readlong:
        Next_state=Writelong;
    Writelong:
        if(sdram_ac)
        Next_state=Writelong1;
    
    Writelong1:
    if(sdram_addr_max<=sdram_addr)
         Next_state=Examine;
    else if (sdram_wait)
        Next_state=Pauselong;
    else
        Next_state=Writelong;


    Examine:
    if(DFJK_valid[DFJK4321])
        Next_state=Read;
    else
        Next_state=To_next;
    To_next:
    if(DFJK4321==4'b1111)
        Next_state=Done;
    else if(Key_type[DFJK4321+1]==2'b10)
        Next_state=Examinelong;
    else
        Next_state=Examine;

    Read:
        Next_state=Read1;
    Read1:
        Next_state=Write;
    Write:
        if(sdram_ac)
            Next_state=Write1;
    Write1:
    if(sdram_addr_max<=sdram_addr)
        Next_state=To_next;
    else if(sdram_wait)
        Next_state=Pause;
    else
        Next_state=Read;
    Done:
        if(new_frame)
            Next_state=Halted;
    Pause:
        if(~sdram_wait)
            Next_state=Read;
    Pauselong:
        if(~sdram_wait)
            Next_state=Writelong;
    endcase
end

always_comb
begin
ram_rdaddr_x=ram_rdaddr;
done=0;
sdram_wr=0;
sdram_addr_x=sdram_addr;
DFJK4321_x=DFJK4321;
busy=0;
rd_req=0;
is_long=0;
if(frame_flip)
    sdram_addr_max=wraddr_offset1+(Pos_Y+Dist_Y)*40+((Pos_X+Dist_X)/16)-1;
else
    sdram_addr_max=wraddr_offset0+(Pos_Y+Dist_Y)*40+((Pos_X+Dist_X)/16)-1;
case(State)
Halted:
begin
    sdram_addr_x=frame_flip?wraddr_offset1+(Pos_Y)*40+(Pos_X/16):wraddr_offset0+(Pos_Y)*40+(Pos_X/16);
    ram_rdaddr_x=0;
    DFJK4321_x=4'b0000;
end
Examine:
begin
    busy=1;
    if(DFJK4321[3]==DFJK4321[2])
    ram_rdaddr_x=d_k_ram_offset;
    else
    ram_rdaddr_x=f_j_ram_offset;
    sdram_addr_x=frame_flip?wraddr_offset1+(Pos_Y)*40+(Pos_X/16):wraddr_offset0+(Pos_Y)*40+(Pos_X/16);
end
Examinelong:
begin
    is_long=1;
    busy=1;
    if(~DFJK_valid[DFJK4321])
        begin
            sdram_addr_x=frame_flip?wraddr_offset1+(Pos_X/16):wraddr_offset0+(Pos_X/16);
            if(DFJK4321[1:0]!=2'b00)
                sdram_addr_max=frame_flip?wraddr_offset1+(vaild_temp[DFJK4321-1])*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(vaild_temp[DFJK4321-1])*40+((Pos_X+Dist_X)/16)-1;
            else
                sdram_addr_max=frame_flip?wraddr_offset1+(offset_y-mv_speed*7)*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(offset_y-mv_speed*7)*40+((Pos_X+Dist_X)/16)-1;
        end
    else
        begin
            sdram_addr_x=frame_flip?wraddr_offset1+(Pos_Y)*40+(Pos_X/16):wraddr_offset0+(Pos_Y)*40+(Pos_X/16);
            if(DFJK4321[1:0]!=2'b00)
                sdram_addr_max=frame_flip?wraddr_offset1+(vaild_temp[DFJK4321-1])*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(vaild_temp[DFJK4321-1])*40+((Pos_X+Dist_X)/16)-1;
            else
                sdram_addr_max=frame_flip?wraddr_offset1+(offset_y-mv_speed*7)*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(offset_y-mv_speed*7)*40+((Pos_X+Dist_X)/16)-1;
        end
end
Readlong:
begin
    is_long=1;
    rd_req=1;
    busy=1;
    if(DFJK4321[1:0]!=2'b00)
        sdram_addr_max=frame_flip?wraddr_offset1+(vaild_temp[DFJK4321-1])*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(vaild_temp[DFJK4321-1])*40+((Pos_X+Dist_X)/16)-1;
    else
        sdram_addr_max=frame_flip?wraddr_offset1+(offset_y+-mv_speed*7)*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(offset_y-mv_speed*7)*40+((Pos_X+Dist_X)/16)-1;
end

Writelong:
begin
    is_long=1;
    sdram_wr=1;
    busy=1;
    if(DFJK4321[1:0]!=2'b00)
        sdram_addr_max=frame_flip?wraddr_offset1+(vaild_temp[DFJK4321-1])*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(vaild_temp[DFJK4321-1])*40+((Pos_X+Dist_X)/16)-1;
    else
        sdram_addr_max=frame_flip?wraddr_offset1+(offset_y-mv_speed*7)*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(offset_y-mv_speed*7)*40+((Pos_X+Dist_X)/16)-1;
end
Writelong1:
begin
    is_long=1;
    busy=1;
    if(DFJK4321[1:0]!=2'b00)
        sdram_addr_max=frame_flip?wraddr_offset1+(vaild_temp[DFJK4321-1])*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(vaild_temp[DFJK4321-1])*40+((Pos_X+Dist_X)/16)-1;
    else
        sdram_addr_max=frame_flip?wraddr_offset1+(offset_y-mv_speed*7)*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(offset_y-mv_speed*7)*40+((Pos_X+Dist_X)/16)-1;
	 case(frame_flip)
	 1:
        sdram_addr_x=(sdram_addr-wraddr_offset1-(Pos_X/16))%40==2?sdram_addr+wraddr_key_shift_offset+1:sdram_addr+1;
	 0:
	    sdram_addr_x=(sdram_addr-wraddr_offset0-(Pos_X/16))%40==2?sdram_addr+wraddr_key_shift_offset+1:sdram_addr+1;
	 endcase
end
To_next:
begin
    busy=1;
    DFJK4321_x=DFJK4321+1;
end

Read:
busy=1;

Read1:
begin
    busy=1;
    rd_req=1;
    ram_rdaddr_x=ram_rdaddr+1;
end
Write:
begin
    busy=1;
    sdram_wr=1;
end
Write1:
begin
    busy=1;
	 case(frame_flip)
	 1:
    sdram_addr_x=(sdram_addr-wraddr_offset1-(Pos_X/16))%40==2?sdram_addr+wraddr_key_shift_offset+1:sdram_addr+1;
	 0:
	 sdram_addr_x=(sdram_addr-wraddr_offset0-(Pos_X/16))%40==2?sdram_addr+wraddr_key_shift_offset+1:sdram_addr+1;
	 endcase
end
Done:
begin
    done=1;
end
Pause:
;
Pauselong:
is_long=1;

endcase
end


endmodule