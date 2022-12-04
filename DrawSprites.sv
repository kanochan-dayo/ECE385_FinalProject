module Draw_sprites(
input clk,reset,sdram_wait,sdram_ac,ram_wr,new_frame,
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

parameter mv_speed=5;

parameter d_k_ram_offset=0;
parameter f_j_ram_offset=36;

key_d d();
key_f f();
key_j j();
key_k k();
logic [7:0] d_addr,f_addr,j_addr,k_addr;
logic [7:0] d_addr_x,f_addr_x,j_addr_x,k_addr_x;

logic [127:0] d_data,f_data,j_data,k_data,ram_data_out;
logic [3:0] DFJK4321,DFJK4321_x;
logic [8:0] ram_rdaddr;
logic [3:0] DFJK_prestate[1:0];

enum logic[2:0] {Key,Score,Combo}Draw_type,Draw_type_x;

enum logic [3:0]{Halted,Read,Write,Write1,Pause,Done} State,Next_state;

Sprite_ram ram(
	.clock(clk),
	.data(ram_data),
	.rdaddress(ram_rdaddr),
	.wraddress(ram_wraddr),
	.wren(ram_wr),
	.q(ram_data_out));

logic d_next,f_next,j_next,k_next;
logic d_changed,f_changed,j_changed,k_changed;
assign d_changed=(DFJK_prestate[0][3]!=DFJK_prestate[1][3])?1'b1:1'b0;
assign f_changed=(DFJK_prestate[0][2]!=DFJK_prestate[1][2])?1'b1:1'b0;
assign j_changed=(DFJK_prestate[0][1]!=DFJK_prestate[1][1])?1'b1:1'b0;
assign k_changed=(DFJK_prestate[0][0]!=DFJK_prestate[1][0])?1'b1:1'b0;

always_ff @(posedge new_frame or posedge reset)
 begin 
    if(!reset)
    begin
        d_addr<=d_addr_x;
        f_addr<=f_addr_x;
        j_addr<=j_addr_x;
        k_addr<=k_addr_x;
        DFJK_prestate[0]<=DFJK;
        DFJK_prestate[1]<=DFJK_prestate[0];
        d_next<=d_next_x;
        f_next<=f_next_x;
        j_next<=j_next_x;
        k_next<=k_next_x;
        precise_d<=precise_d_x;
        precise_f<=precise_f_x;
        precise_j<=precise_j_x;
        precise_k<=precise_k_x;
    end
    else
    begin
        d_addr<=0;
        f_addr<=0;
        j_addr<=0;
        k_addr<=0;
        DFJK_prestate[0]<=DFJK;
        DFJK_prestate[1]<=DFJK;
        d_next<=0;
        f_next<=0;
        j_next<=0;
        k_next<=0;
        precise_d<=0;
        precise_f<=0;
        precise_j<=0;
        precise_k<=0;
    end
end
always_comb 
begin
    precise_d_x=precise_d;
    precise_f_x=precise_f;
    precise_j_x=precise_j;
    precise_k_x=precise_k;
    d_next=precise_d[0]|precise_d[1];
    f_next=precise_f[0]|precise_f[1];
    j_next=precise_j[0]|precise_j[1];
    k_next=precise_k[0]|precise_k[1];
    if(d0_key[13:0]==un_time) 
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
// logic d_next_x,f_next_x,j_next_x,k_next_x;

// always_comb begin 
//     d_next_x=d_next;
//     f_next_x=f_next;
//     j_next_x=j_next;
//     k_next_x=k_next;
//     precise_d_x=precise_d;
//     precise_f_x=precise_f;
//     precise_j_x=precise_j;
//     precise_k_x=precise_k;
    // if(d0_key[13:0]==un_time) 
    // begin
    //     d_next_x=1;
    //     precise_d_x=2'b11;
    // end
    // else if(d_changed==0)
    // begin
    //     d_next_x=0;
    //     precise_d_x=2'b00;
    // end
    // else
    // begin
    //     if(d0_key[15:14]==2'b10)
    //     begin
    //             d_next_x=1;
    //             if (d0_key[13:0]-un_time>15)
    //             begin
    //                 precise_d_x=2'b11;
    //             end
    //             else if (d0_key[13:0]-un_time>7)
    //             begin
    //                 precise_d_x=2'b10;
    //             end
    //             else
    //             begin
    //                 precise_d_x=2'b01;
    //             end
    //     end
    //     else if(DFJK[3]==0)
    //     begin
    //         d_next_x=0;
    //         precise_d_x=2'b00;
    //     end
    //     else if(d0_key[13:0]-un_time>27)
    //     begin
    //         d_next_x=0;
    //         precise_d_x=2'b00;
    //     end
    //     else if(d0_key[13:0]-un_time>15)
    //     begin
    //         d_next_x=1;
    //         precise_d_x=2'b11;
    //     end
    //     else if(d0_key[13:0]-un_time>7)
    //     begin
    //         d_next_x=1;
    //         precise_d_x=2'b10;
    //     end
    //     else
    //     begin
    //         d_next_x=1;
    //         precise_d_x=2'b01;
    //     end
    // end
    // if(f0_key[13:0]==un_time)
    // begin
    //     f_next_x=1;
    //     precise_f_x=2'b11;
    // end
    // else if(f_changed==0)
    // begin
    //     f_next_x=0;
    //     precise_f_x=2'b00;
    // end
//     else
//     begin
//         if(f0_key[15:14]==2'b10)
//         begin
//                 f_next_x=1;
//                 if (f0_key[13:0]-un_time>15)
//                 begin
//                     precise_f_x=2'b11;
//                 end
//                 else if (f0_key[13:0]-un_time>7)
//                 begin
//                     precise_f_x=2'b10;
//                 end
//                 else
//                 begin
//                     precise_f_x=2'b01;
//                 end
//         end
//         else if(DFJK[2]==0)
//         begin
//             f_next_x=0;
//             precise_f_x=2'b00;
//         end
//         else if(f0_key[13:0]-un_time>27)
//         begin
//             f_next_x=0;
//             precise_f_x=2'b00;
//         end
//         else if(f0_key[13:0]-un_time>15)
//         begin
//             f_next_x=1;
//             precise_f_x=2'b11;
//         end
//         else if(f0_key[13:0]-un_time>7)
//         begin
//             f_next_x=1;
//             precise_f_x=2'b10;
//         end
//         else
//         begin
//             f_next_x=1;
//             precise_f_x=2'b01;
//         end
//     end
//     if(j0_key[13:0]==un_time)
//     begin
//         j_next_x=1;
//         precise_j_x=2'b11;
//     end
//     else if(j_changed==0)
//     begin
//         j_next_x=0;
//         precise_j_x=2'b00;
//     end
//     else
//     begin
//         if(j0_key[15:14]==2'b10)
//         begin
//                 j_next_x=1;
//                 if (j0_key[13:0]-un_time>15)
//                 begin
//                     precise_j_x=2'b11;
//                 end
//                 else if (j0_key[13:0]-un_time>7)
//                 begin
//                     precise_j_x=2'b10;
//                 end
//                 else
//                 begin
//                     precise_j_x=2'b01;
//                 end
//         end
//         else if(DFJK[1]==0)
//         begin
//             j_next_x=0;
//             precise_j_x=2'b00;
//         end
//         else if(j0_key[13:0]-un_time>27)
//         begin
//             j_next_x=0;
//             precise_j_x=2'b00;
//         end
//         else if(j0_key[13:0]-un_time>15)
//         begin
//             j_next_x=1;
//             precise_j_x=2'b11;
//         end
//         else if(j0_key[13:0]-un_time>7)
//         begin
//             j_next_x=1;
//             precise_j_x=2'b10;
//         end
//         else
//         begin
//             j_next_x=1;
//             precise_j_x=2'b01;
//         end
//     end
//     if(k0_key[13:0]==un_time)
//     begin
//         k_next_x=1;
//         precise_k_x=2'b11;
//     end
//     else if(k_changed==0)
//     begin
//         k_next_x=0;
//         precise_k_x=2'b00;
//     end
//     else
//     begin
//         if(k0_key[15:14]==2'b10)
//         begin
//                 k_next_x=1;
//                 if (k0_key[13:0]-un_time>15)
//                 begin
//                     precise_k_x=2'b11;
//                 end
//                 else if (k0_key[13:0]-un_time>7)
//                 begin
//                     precise_k_x=2'b10;
//                 end
//                 else
//                 begin
//                     precise_k_x=2'b01;
//                 end
//         end
//         else if(DFJK[0]==0)
//         begin
//             k_next_x=0;
//             precise_k_x=2'b00;
//         end
//         else if(k0_key[13:0]-un_time>27)
//         begin
//             k_next_x=0;
//             precise_k_x=2'b00;
//         end
//         else if(k0_key[13:0]-un_time>15)
//         begin
//             k_next_x=1;
//             precise_k_x=2'b11;
//         end
//         else if(k0_key[13:0]-un_time>7)
//         begin
//             k_next_x=1;
//             precise_k_x=2'b10;
//         end
//         else
//         begin
//             k_next_x=1;
//             precise_k_x=2'b01;
//         end
//     end
// end

always_comb 
begin
    d_addr_x=d_addr;
    f_addr_x=f_addr;
    j_addr_x=j_addr;
    k_addr_x=k_addr;
    if(d_next==1)
    begin
        d_addr_x=d_addr_x+1;
    end
    if(f_next==1)
    begin
        f_addr_x=f_addr_x+1;
    end
    if(j_next==1)
    begin
        j_addr_x=j_addr_x+1;
    end
    if(k_next==1)
    begin
        k_addr_x=k_addr_x+1;
    end
end

logic [15:0] d0_key,d1_key,d2_key,d3_key,f0_key,f1_key,f2_key,f3_key,j0_key,j1_key,j2_key,j3_key,k0_key,k1_key,k2_key,k3_key;
logic [7:0] d_sdram_addr,f_sdram_addr,j_sdram_addr,k_sdram_addr;

logic [1:0] precise_d,precise_f,precise_j,precise_k;
logic [1:0] precise_d_x,precise_f_x,precise_j_x,precise_k_x;
endmodule