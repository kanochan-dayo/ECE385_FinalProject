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
    8'd0,8'd17,8'd34,8'd51,8'd68,8'd85,8'd102,8'd119,8'd136,8'd153
};

parameter [0:9][8:0] combo_ram_addr_start={
    9'd302,9'd318,9'd334,9'd350,9'd366,9'd382,9'd398,9'd414,9'd430,9'd446
};

parameter combo_default_ram_start=170;
parameter combo_default_sdram_start=3325;
parameter combo_default_sdram_end=4368;
parameter combo_origin_ram_start=278;

parameter [4:0][11:0] combo_sdram_addr_start={
    12'd3325,12'd3765,12'd3766,12'd3767,12'd3768
};
parameter [4:0][12:0] combo_sdram_addr_end={
    13'd3568,13'd4405,13'd4406,13'd4407,13'd4408
};

parameter [5:0][14:0]score_sdram_addr_start={
15'd16324,15'd16325,15'd16326,15'd16327,15'd16328,15'd16329
};
parameter [5:0][14:0]score_sdram_addr_end={
15'd17004,15'd17005,15'd17006,15'd17007,15'd17008,15'd17009
};
parameter wraddr_offset0=22'h100000;
parameter wraddr_offset1=22'h200000;

parameter [0:3][9:0]precise_ram_start={10'd0,10'd462,10'd514,10'd566};
parameter precise_sdram_start=9805;
parameter precise_sdram_addr_end=10328;

score_ram ram1(
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
logic [3:0]combo_digit[3:0];
always_comb
begin
    score_digit[0]=score_now%10;
    score_digit[1]=(score_now/10)%10;
    score_digit[2]=(score_now/100)%10;
    score_digit[3]=(score_now/1000)%10;
    score_digit[4]=(score_now/10000)%10;
    score_digit[5]=(score_now/100000)%10;
    combo_digit[0]=combo_now%10;
    combo_digit[1]=(combo_now/10)%10;
    combo_digit[2]=(combo_now/100)%10;
    combo_digit[3]=0;
end

logic [3:0] score_index,score_index_x;
logic [2:0] combo_index,combo_index_x;
logic [9:0]ram_rdaddr_x;
logic [9:0]ram_rdaddr;
logic [127:0]ram_data_out;
logic [21:0] sdram_addr_x;
enum logic [4:0]{Halted,Read_s,Read_s1,Write_s,Write_s1,Read_p,Read_p1,Write_p,Write_p1,Pause_p,C2P,
Read_c,Read_c1,Write_c,Write_c1,To_next_s,S2C,To_next_c,Pause_s,Pause_c,Done} State,Next_state;


always_ff @(posedge clk or posedge reset)begin
    if(reset)begin
        score_index<=0;
        combo_index<=0;
        ram_rdaddr<=0;
        sdram_addr<=0;
        State<=Halted;
    end
    else begin
        sdram_addr<=sdram_addr_x;
        ram_rdaddr<=ram_rdaddr_x;
        score_index<=score_index_x;
        combo_index<=combo_index_x;
        State<=Next_state;
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
    Read_c:
        Next_state=Read_c1;
    Read_p:
        Next_state=Read_p1;
    Read_s1:
        Next_state=Write_s;
    Read_c1:
        Next_state=Write_c;
    Read_p1:
        Next_state=Write_p;
    Write_s:
        if(sdram_ac)
            Next_state=Write_s1;
    Write_c:
        if(sdram_ac)
            Next_state=Write_c1;
    Write_p:
        if(sdram_ac)
            Next_state=Write_p1;
    Write_c1:
        if(combo_now==0)
        begin
            if(sdram_addr-(frame_flip?wraddr_offset1:wraddr_offset0)==combo_default_sdram_end)
                Next_state=C2P;
            else if(sdram_wait)
                Next_state=Pause_c;
            else
                Next_state=Read_c;
        end
        else
        begin
            if(sdram_addr-(frame_flip?wraddr_offset1:wraddr_offset0)==combo_sdram_addr_end[combo_index])
                Next_state=To_next_c;
            else if(sdram_wait)
                Next_state=Pause_c;
            else
                Next_state=Read_c;
        end
    Write_s1:
        if((sdram_addr-(frame_flip?wraddr_offset1:wraddr_offset0))==score_sdram_addr_end[score_index])
            Next_state=To_next_s;
        else if(sdram_wait)
            Next_state=Pause_s;
        else
            Next_state=Read_s;
    Write_p1:
        if((sdram_addr-(frame_flip?wraddr_offset1:wraddr_offset0))==precise_sdram_addr_end)
            Next_state=Done;
        else if(sdram_wait)
            Next_state=Pause_p;
        else
            Next_state=Read_p;
    To_next_s:
        if(score_index==3'b101)
            Next_state=S2C;
        else if(sdram_wait)
            Next_state=Pause_s;
        else
            Next_state=Read_s;
    To_next_c:
        if(combo_index==3'b100)
            Next_state=C2P;
        else if(sdram_wait)
            Next_state=Pause_c;
        else
            Next_state=Read_c;
    C2P:
        if(precise==0)
            Next_state=Done;
        else if(sdram_wait)
            Next_state=Pause_p;
        else
            Next_state=Read_p;
    S2C:
        if(sdram_wait)
            Next_state=Pause_c;
        else
            Next_state=Read_c;
    Pause_s:
        if(~sdram_wait)
            Next_state=Read_s;
	Pause_c:
        if(~sdram_wait)
            Next_state=Read_c;
    Pause_p:
        if(~sdram_wait)
            Next_state=Read_p;
    Done:
        if(new_frame)
            Next_state=Halted;
    endcase
end


always_comb
begin
    busy=1'b0;
    rd_req=1'b0;
    ram_rdaddr_x=ram_rdaddr;
    sdram_addr_x=sdram_addr;
    score_index_x=score_index;
    combo_index_x=combo_index;
    sdram_wr=1'b0;
    done=1'b0;
    case(State)
    Halted:
    begin
        ram_rdaddr_x=score_ram_addr_start[score_digit[score_index]];
        score_index_x=0;
        combo_index_x=0;
        sdram_addr_x=frame_flip?wraddr_offset1+score_sdram_addr_start[score_index]:wraddr_offset0+score_sdram_addr_start[score_index];
    end
    Read_s:
    begin
        busy=1'b1;
    end
    Read_c:
    begin
        busy=1'b1;
    end
    Read_p:
    begin
        busy=1'b1;
    end
    Read_s1:
    begin
        busy=1'b1;
        rd_req=1'b1;
        ram_rdaddr_x=ram_rdaddr+1;
    end
    Read_c1:
    begin
        busy=1'b1;
        rd_req=1'b1;
        ram_rdaddr_x=ram_rdaddr+1;
    end
    Read_p1:
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
    Write_c:
    begin
        busy=1'b1;
        sdram_wr=1'b1;
    end
    Write_p:
    begin
        busy=1'b1;
        sdram_wr=1'b1;
    end
    Write_s1:
    begin
        busy=1'b1;
        sdram_addr_x=sdram_addr+40;
    end
    Write_c1:
    begin
        busy=1'b1;
        if(combo_now==0)
            begin
                if((sdram_addr-(frame_flip?wraddr_offset1:wraddr_offset0))%40==8)
                    sdram_addr_x=sdram_addr+37;
                else
                    sdram_addr_x=sdram_addr+1;
            end
        else
        begin
            if(combo_index==3'b100)
            begin
                if((sdram_addr-(frame_flip?wraddr_offset1:wraddr_offset0))%40==8)
                    sdram_addr_x=sdram_addr+37;
                else
                    sdram_addr_x=sdram_addr+1;
            end
            else
            sdram_addr_x=sdram_addr+40;
        end
    end
    Write_p1:
    begin
        busy=1'b1;
        if((sdram_addr-(frame_flip?wraddr_offset1:wraddr_offset0))%40==8)
            sdram_addr_x=sdram_addr+37;
        else
            sdram_addr_x=sdram_addr+1;
    end
    To_next_s:
    begin
        busy=1'b1;
        ram_rdaddr_x=score_ram_addr_start[score_digit[score_index+1]];
        score_index_x=score_index+1;
        sdram_addr_x=frame_flip?wraddr_offset1+score_sdram_addr_start[score_index+1]:wraddr_offset0+score_sdram_addr_start[score_index+1];
    end
    To_next_c:
    begin
        busy=1'b1;
		  if(combo_index==3'b011)
		  ram_rdaddr_x=combo_origin_ram_start;
		  else
        ram_rdaddr_x=combo_ram_addr_start[combo_digit[combo_index+1]];
        combo_index_x=combo_index+1;
        sdram_addr_x=frame_flip?wraddr_offset1+combo_sdram_addr_start[combo_index+1]:wraddr_offset0+combo_sdram_addr_start[combo_index+1];
    end
    Done:
    begin
        done=1'b1;
    end
    Pause_s:
    ;
    Pause_c:
    ;
    Pause_p:
    ;
    S2C:
    begin
		  busy=1;
        if(combo_now==0)
        begin
            ram_rdaddr_x=combo_default_ram_start;
            combo_index_x=0;
            score_index_x=0;
            sdram_addr_x=frame_flip?wraddr_offset1+combo_default_sdram_start:wraddr_offset0+combo_default_sdram_start;
        end
        else
        begin
            ram_rdaddr_x=combo_ram_addr_start[combo_digit[combo_index]];
            score_index_x=0;
            combo_index_x=0;
            sdram_addr_x=frame_flip?wraddr_offset1+combo_sdram_addr_start[combo_index]:wraddr_offset0+combo_sdram_addr_start[combo_index];
        end
    end
    C2P:
    begin
            busy=1;
            ram_rdaddr_x=precise_ram_start[precise];
            score_index_x=0;
            combo_index_x=0;
            sdram_addr_x=frame_flip?wraddr_offset1+precise_sdram_start:wraddr_offset0+precise_sdram_start;
    end
    endcase
end

endmodule