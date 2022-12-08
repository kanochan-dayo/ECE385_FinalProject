module keycode_machine (
input [7:0] keycode,
input clk,reset,stop_sign,
output keyboard_start
);
always_ff @(posedge clk or posedge reset)
begin
if(reset)
begin
keyboard_start<=1'b0;
end
else
begin
    if(keycode==40)
    keyboard_start<=1;
    else
    keyboard_start<=keyboard_start;
end
end

//enum logic
endmodule
