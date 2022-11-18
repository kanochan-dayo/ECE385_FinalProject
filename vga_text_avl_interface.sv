/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
`define NUM_REGS 8 //80*30 characters / 4 characters per register
//`define CTRL_REG 600 //index of control register

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

logic [31:0] LOCAL_REG       [`NUM_REGS]; // Registers
logic [31:0] data_in,avl_out,reg_out;
logic [11:0] fcolor_in,bcolor_in;
//put other local variables here
logic pixel_clk,sync,blank,flag,flag1;
logic [9:0] DrawX,DrawY;
logic [10:0] data_addr;
logic [3:0] fcolor_addr,bcolor_addr;


//Declare submodules..e.g. VGA controller, ROMS, etc
vga_controller vga_ctr0( .Clk(CLK),.Reset(RESET),.*);   // vertical coordinate
color_mapper cm0(.Red(red),.Green(green),.Blue(blue),.*);
onchip_vram vram0(	.address_a(AVL_ADDR[10:0]),.
	address_b(data_addr),.
	byteena_a(AVL_BYTE_EN),.
	clock(CLK),.
	data_a(AVL_WRITEDATA),.
	data_b(32'b0),.
	rden_a(AVL_READ&&AVL_CS&&(~flag)),.
	rden_b(1'b1),.
	wren_a(AVL_WRITE&&AVL_CS&&(~flag)),.
	wren_b(1'b0),.
	q_a(avl_out),.
	q_b(data_in));

assign flag=AVL_ADDR[11];
always_comb
begin
unique case(flag)
1'b1:AVL_READDATA=reg_out;
1'b0:AVL_READDATA=avl_out;
endcase
end

//always_ff @(posedge DrawX[3])
//begin
//if(blank)
//begin
//data_in<=data_inn;
//case(data_addr)
//1200:
//data_addrr<=0;
//default:
//data_addrr<=(data_addr+1);
//endcase
//end
//end

// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff
always_ff @(posedge CLK) begin
if (AVL_CS&&flag)
begin
if (AVL_READ)
begin
reg_out<=LOCAL_REG[AVL_ADDR[2:0]];
end
else if (AVL_WRITE)
begin
unique case(AVL_BYTE_EN)
4'b1111:
LOCAL_REG[AVL_ADDR[2:0]]<=AVL_WRITEDATA;
4'b1100:
LOCAL_REG[AVL_ADDR[2:0]][31:16]<=AVL_WRITEDATA[31:16];
4'b0011:
LOCAL_REG[AVL_ADDR[2:0]][15:0]<=AVL_WRITEDATA[15:0];
4'b1000:
LOCAL_REG[AVL_ADDR[2:0]][31:24]<=AVL_WRITEDATA[31:24];
4'b0100:
LOCAL_REG[AVL_ADDR[2:0]][23:16]<=AVL_WRITEDATA[23:16];
4'b0010:
LOCAL_REG[AVL_ADDR[2:0]][15:8]<=AVL_WRITEDATA[15:8];
4'b0001:
LOCAL_REG[AVL_ADDR[2:0]][7:0]<=AVL_WRITEDATA[7:0];
default:;
endcase
end
end
end

always_comb
begin
unique case(fcolor_addr[0])
1'b1:
fcolor_in=LOCAL_REG[fcolor_addr[3:1]][24:13];
1'b0:
fcolor_in=LOCAL_REG[fcolor_addr[3:1]][12:1];
endcase
unique case(bcolor_addr[0])
1'b1:
bcolor_in=LOCAL_REG[bcolor_addr[3:1]][24:13];
1'b0:
bcolor_in=LOCAL_REG[bcolor_addr[3:1]][12:1];
endcase
end

//handle drawing (may either be combinational or sequential - or both).
		

endmodule
