module Draw_score_combo(
input clk,reset,sdram_wait,sdram_ac,ram_wr,new_frame,frame_flip,
input [15:0] un_time,
input [9:0] ram_wraddr,
input [127:0]ram_data,
input [12:0] score,
input [3:0] combo,
input [1:0] precise,
output [127:0]sdram_data,
output [21:0]sdram_addr,
output sdram_wr,busy,done,
output [15:0]sdram_be
);
parameter transparent=8'hFF;
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

parameter [0:9][7:0]score_ram_addr_start={
    8'd72,8'd89,8'd106,8'd123,8'd140,8'd157,8'd174,8'd191,8'd208,8'd225
};

parameter [5:0][14:0]score_sdram_addr_start={
15'd16324,15'd16325,15'd16326,15'd16327,15'd16328,15'd16329
};
parameter [5:0][14:0]score_sdram_addr_end={
15'd17004,15'd17005,15'd17006,15'd17007,15'd17008,15'd17009
};
parameter wraddr_offset0=22'h100000;
parameter wraddr_offset1=22'h200000;

Sprite_ram ram1(
	.clock(clk),
	.data(ram_data),
	.rdaddress(ram_rdaddr),
	.wraddress(ram_wraddr),
	.wren(ram_wr),
	.q(ram_data_out));

logic[9:0] combo_now;
logic[19:0] score_now;
logic rd_req;

always_ff @(posedge rd_req or posedge reset)
begin
    if(reset)
        sdram_data<=0;
    else 
        sdram_data<=ram_data_out;
end

always_ff @(posedge new_frame or posedge reset)begin
    if(reset)begin
        combo_now<=0;
        score_now<=0;

    end
    else begin
        if (precise[1]==1'b1)
            combo_now<=0;
        else
            combo_now<=combo+combo_now;
        score_now<=score+score_now;

    end
end

logic [3:0]score_digit[5:0];
logic [3:0]combo_digit[2:0];
always_comb
begin
    score_digit[0]=score_now[3:0]%10;
    score_digit[1]=(score_now[6:0]/10)%10;
    score_digit[2]=(score_now[9:0]/100)%10;
    score_digit[3]=(score_now[13:0]/1000)%10;
    score_digit[4]=(score_now[16:0]/10000)%10;
    score_digit[5]=(score_now[19:0]/100000)%10;
    combo_digit[0]=combo_now[3:0]%10;
    combo_digit[1]=(combo_now[6:0]/10)%10;
    combo_digit[2]=(combo_now[9:0]/100)%10;
end

logic [3:0] score_index,score_index_x;
logic [1:0] combo_index,combo_index_x;
logic [8:0]ram_rdaddr_x;
logic [127:0]ram_data_out;
logic [21:0] sdram_addr_x;
enum logic [3:0]{Halted,Read_s,Read_s1,Write_s,Write_s1,
Read_c,Read_c1,Writec_s,Write_c1,To_next_s,To_next_c,Pause_s,Pause_c,Done} State,Next_state;
enum logic[2:0] {Score,Combo,Static}Draw_type,Draw_type_x;

always_ff @(posedge clk or posedge reset)begin
    if(reset)begin
        score_index<=0;
        combo_index<=0;
        ram_rdaddr<=0;
        sdram_addr<=0;
        State<=Halted;
		  Draw_type<=Score;
    end
    else begin
        sdram_addr<=sdram_addr_x;
        ram_rdaddr<=ram_rdaddr_x;
        score_index<=score_index_x;
        combo_index<=combo_index_x;
        State<=Next_state;
		  Draw_type<=Draw_type_x;
    end
end

always_comb
begin
    Next_state=State;
    case(State)
    Halted:
        if(~sdram_wait)
            Next_state=Read_s;
    Read_s:
        Next_state=Read_s1;
    Read_s1:
        Next_state=Write_s;
    Write_s:
        if(sdram_ac)
            Next_state=Write_s1;
    Write_s1:
        if((sdram_addr-(frame_flip?wraddr_offset1:wraddr_offset0))==score_sdram_addr_end[score_index])
            Next_state=To_next_s;
        else if(sdram_wait)
            Next_state=Pause_s;
        else
            Next_state=Read_s;
    To_next_s:
        if(score_index==3'b101)
            Next_state=Done;
        else if(sdram_wait)
            Next_state=Pause_s;
        else
            Next_state=Read_s;
    Pause_s:
        if(~sdram_wait)
            Next_state=Read_s;
    Done:
        if(new_frame)
            Next_state=Halted;
    endcase
end

logic [8:0]ram_rdaddr;

always_comb
begin
    busy=1'b0;
    rd_req=1'b0;
    ram_rdaddr_x=ram_rdaddr;
    sdram_addr_x=sdram_addr;
    score_index_x=score_index;
    combo_index_x=combo_index;
    Draw_type_x=Draw_type;
    sdram_wr=1'b0;
    done=1'b0;
    case(State)
    Halted:
    begin
        ram_rdaddr_x=score_ram_addr_start[score_digit[score_index]];
        Draw_type_x=Score;
        score_index_x=0;
        sdram_addr_x=frame_flip?wraddr_offset1+score_sdram_addr_start[score_index]:wraddr_offset0+score_sdram_addr_start[score_index];
    end
    Read_s:
    begin
        busy=1'b1;
    end
    Read_s1:
    begin
        busy=1'b1;
        rd_req=1'b1;
        ram_rdaddr_x=ram_rdaddr+1;
    end
    Write_s:
    begin
        busy=1'b1;
        sdram_wr=1'b1;
    end
    Write_s1:
    begin
        busy=1'b1;
        sdram_addr_x=sdram_addr+40;
    end
    To_next_s:
    begin
        busy=1'b1;
        ram_rdaddr_x=score_ram_addr_start[score_digit[score_index+1]];
        score_index_x=score_index+1;
        sdram_addr_x=frame_flip?wraddr_offset1+score_sdram_addr_start[score_index+1]:wraddr_offset0+score_sdram_addr_start[score_index+1];
    end
    Done:
    begin
        done=1'b1;
    end
    Pause_s:
    ;
    endcase
end

endmodule