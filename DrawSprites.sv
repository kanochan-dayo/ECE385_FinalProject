module Draw_sprites(
input clk,reset,sdram_wait,sdram_ac,ram_wr,new_frame,frame_flip,
input [15:0] un_time,
input [3:0]DFJK,
input [9:0] ram_wraddr,
input [127:0]ram_data,
output [127:0]sdram_data,
output [21:0]sdram_addr,
output sdram_wr,busy,done,
output [15:0]sdram_be
);
parameter transparent=8'hFF;
// logic sdram_ac,sdram_wr;
// logic [21:0]sdram_addr;

// always_comb
// begin
// case(frame_flip)
// 1'b1:
// if((sdram_addr)>=wraddr_offset1)
// begin
//     sdram_addr1=sdram_addr;
//     sdram_wr1=sdram_wr;
//     sdram_ac=sdram_ac1;
// end
//     else
// begin
//     sdram_addr1=wraddr_offset1;
//     sdram_wr1=1'b0;
//     sdram_ac=1'b1;
// end
// 1'b0:
// if((sdram_addr)>=wraddr_offset0)
// begin
//     sdram_addr1=sdram_addr;
//     sdram_wr1=sdram_wr;
//     sdram_ac=sdram_ac1;
// end
//     else
// begin
//     sdram_addr1=wraddr_offset0;
//     sdram_wr1=1'b0;
//     sdram_ac=1'b1;
// end

// endcase
// end


assign sdram_be[0]=(sdram_data[7:0]!=transparent);
assign sdram_be[1]=(sdram_data[15:8]!=transparent);
assign sdram_be[2]=(sdram_data[23:16]!=transparent);
assign sdram_be[3]=(sdram_data[31:24]!=transparent);
assign sdram_be[4]=(sdram_data[39:32]!=transparent);
assign sdram_be[5]=(sdram_data[47:40]!=transparent);
assign sdram_be[6]=(sdram_data[55:48]!=transparent);
assign sdram_be[7]=(sdram_data[63:56]!=transparent);
assign sdram_be[8]=(sdram_data[71:64]!=transparent);
assign sdram_be[9]=(sdram_data[79:72]!=transparent);
assign sdram_be[10]=(sdram_data[87:80]!=transparent);
assign sdram_be[11]=(sdram_data[95:88]!=transparent);
assign sdram_be[12]=(sdram_data[103:96]!=transparent);
assign sdram_be[13]=(sdram_data[111:104]!=transparent);
assign sdram_be[14]=(sdram_data[119:112]!=transparent);
assign sdram_be[15]=(sdram_data[127:120]!=transparent);



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

logic [1:0] precise_d,precise_f,precise_j,precise_k;
logic [1:0] precise_d_x,precise_f_x,precise_j_x,precise_k_x;
logic [3:0] DFJK_prestate[1:0];
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






assign d_changed=(DFJK_prestate[0][3]!=DFJK_prestate[1][3])?1'b1:1'b0;
assign f_changed=(DFJK_prestate[0][2]!=DFJK_prestate[1][2])?1'b1:1'b0;
assign j_changed=(DFJK_prestate[0][1]!=DFJK_prestate[1][1])?1'b1:1'b0;
assign k_changed=(DFJK_prestate[0][0]!=DFJK_prestate[1][0])?1'b1:1'b0;

logic d_next,f_next,j_next,k_next;
logic d_changed,f_changed,j_changed,k_changed;

always_ff @(posedge new_frame or posedge reset)
 begin 
    if(reset)
	 begin
        d_addr<=0;
        f_addr<=0;
        j_addr<=0;
        k_addr<=0;
        DFJK_prestate[0]<=DFJK;
        DFJK_prestate[1]<=DFJK;
        precise_d<=0;
        precise_f<=0;
        precise_j<=0;
        precise_k<=0;
    end
	     else
    begin
        d_addr<=d_addr_x;
        f_addr<=f_addr_x;
        j_addr<=j_addr_x;
        k_addr<=k_addr_x;
        DFJK_prestate[0]<=DFJK;
        DFJK_prestate[1]<=DFJK_prestate[0];
        precise_d<=precise_d_x;
        precise_f<=precise_f_x;
        precise_j<=precise_j_x;
        precise_k<=precise_k_x;
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
                if (d0_key[13:0]-un_time>15)
                    precise_d_x=2'b11;
                else if (d0_key[13:0]-un_time>7)
                    precise_d_x=2'b10;
                else
                    precise_d_x=2'b01;
        end
        else if(DFJK[3]==0)
            precise_d_x=2'b00;

        else if(d0_key[13:0]-un_time>27)
            precise_d_x=2'b00;
        else if(d0_key[13:0]-un_time>15)
            precise_d_x=2'b11;
        else if(d0_key[13:0]-un_time>7)
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
                if (f0_key[13:0]-un_time>15)
                    precise_f_x=2'b11;
                else if (f0_key[13:0]-un_time>7)
                    precise_f_x=2'b10;
                else
                    precise_f_x=2'b01;
        end
        else if(DFJK[2]==0)
            precise_f_x=2'b00;

        else if(f0_key[13:0]-un_time>27)
            precise_f_x=2'b00;
        else if(f0_key[13:0]-un_time>15)
            precise_f_x=2'b11;
        else if(f0_key[13:0]-un_time>7)
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
                if (j0_key[13:0]-un_time>15)
                    precise_j_x=2'b11;
                else if (j0_key[13:0]-un_time>7)
                    precise_j_x=2'b10;
                else
                    precise_j_x=2'b01;
        end
        else if(DFJK[1]==0)
            precise_j_x=2'b00;

        else if(j0_key[13:0]-un_time>27)
            precise_j_x=2'b00;
        else if(j0_key[13:0]-un_time>15)
            precise_j_x=2'b11;
        else if(j0_key[13:0]-un_time>7)
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
                if (k0_key[13:0]-un_time>15)
                    precise_k_x=2'b11;
                else if (k0_key[13:0]-un_time>7)
                    precise_k_x=2'b10;
                else
                    precise_k_x=2'b01;
        end
        else if(DFJK[0]==0)
            precise_k_x=2'b00;

        else if(k0_key[13:0]-un_time>27)
            precise_k_x=2'b00;
        else if(k0_key[13:0]-un_time>15)
            precise_k_x=2'b11;
        else if(k0_key[13:0]-un_time>7)
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
parameter mv_speed=12;
parameter d_k_ram_offset=0;
parameter f_j_ram_offset=36;
parameter offset_y=356;
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
    case(Draw_type)
    Key:
    begin
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
endcase
end

enum logic[2:0] {Key,Score,Combo}Draw_type,Draw_type_x;

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
        Draw_type<=Key;
        ram_rdaddr<=0;
        sdram_addr<=0;
    end
    else
    begin
        State<=Next_state;
        DFJK4321<=DFJK4321_x;
        Draw_type<=Draw_type_x;
        ram_rdaddr<=ram_rdaddr_x;
        sdram_addr<=sdram_addr_x;
    end
end

logic rd_req,is_long;
logic [21:0] sdram_addr_max;
logic [8:0]ram_rdaddr_x;
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
    Readlong:
        Next_state=Writelong;
    Writelong:
        if(sdram_ac)
        Next_state=Writelong1;
    
    Writelong1:
    if(sdram_addr_max==sdram_addr)
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
    if(sdram_addr_max==sdram_addr)
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
Draw_type_x=Draw_type;
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
    case(Draw_type)
    Key:
    if(DFJK4321[3]==DFJK4321[2])
    ram_rdaddr_x=d_k_ram_offset;
    else
    ram_rdaddr_x=f_j_ram_offset;
    endcase
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
                sdram_addr_max=frame_flip?wraddr_offset1+(offset_y+Dist_Y)*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(offset_y+Dist_Y)*40+((Pos_X+Dist_X)/16)-1;
        end
    else
        begin
            sdram_addr_x=frame_flip?wraddr_offset1+(Pos_Y)*40+(Pos_X/16):wraddr_offset0+(Pos_Y)*40+(Pos_X/16);
            if(DFJK4321[1:0]!=2'b00)
                sdram_addr_max=frame_flip?wraddr_offset1+(vaild_temp[DFJK4321-1])*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(vaild_temp[DFJK4321-1])*40+((Pos_X+Dist_X)/16)-1;
            else
                sdram_addr_max=frame_flip?wraddr_offset1+(offset_y+Dist_Y)*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(offset_y+Dist_Y)*40+((Pos_X+Dist_X)/16)-1;
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
        sdram_addr_max=frame_flip?wraddr_offset1+(offset_y+Dist_Y)*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(offset_y+Dist_Y)*40+((Pos_X+Dist_X)/16)-1;
end

Writelong:
begin
    is_long=1;
    sdram_wr=1;
    busy=1;
    if(DFJK4321[1:0]!=2'b00)
        sdram_addr_max=frame_flip?wraddr_offset1+(vaild_temp[DFJK4321-1])*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(vaild_temp[DFJK4321-1])*40+((Pos_X+Dist_X)/16)-1;
    else
        sdram_addr_max=frame_flip?wraddr_offset1+(offset_y+Dist_Y)*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(offset_y+Dist_Y)*40+((Pos_X+Dist_X)/16)-1;
end
Writelong1:
begin
    is_long=1;
    busy=1;
    if(DFJK4321[1:0]!=2'b00)
        sdram_addr_max=frame_flip?wraddr_offset1+(vaild_temp[DFJK4321-1])*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(vaild_temp[DFJK4321-1])*40+((Pos_X+Dist_X)/16)-1;
    else
        sdram_addr_max=frame_flip?wraddr_offset1+(offset_y+Dist_Y)*40+((Pos_X+Dist_X)/16)-1:wraddr_offset0+(offset_y+Dist_Y)*40+((Pos_X+Dist_X)/16)-1;
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
;
endcase
end




endmodule