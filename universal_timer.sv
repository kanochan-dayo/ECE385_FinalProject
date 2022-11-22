module universal_timer (
input start_sign,
pause_sign,
clk,
reset,
output stop_sign,
output [9:0] un_time
);

enum logic [1:0] {Halted,run,pause} state,next_state;

always_ff @ (posedge clk)
begin
	state<=next_state;
end

always_comb
begin
	next_state=state;
	case(state)
		Halted:
			if(start_sign)
				next_state=run;
		run:
			if (reset)
				next_state=Halted;
			else if (pause_sign)
				next_state=pause;
			else if (un_time==10'd114514)
				next_state=Halted;
		pause:
			if (reset)
				next_state=Halted;
			else if(!pause_sign)
				next_state=run;

		endcase
	end

always_ff @ (posedge clk)
begin
	case(state)
		Halted:
			un_time=0;
		run:
			un_time<=un_time+1;
		pause:
			un_time<=un_time;
	endcase
end


endmodule
