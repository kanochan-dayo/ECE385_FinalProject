module universal_timer (
input start_sign,
//pause_sign,
new_frame,
clk,
reset,
output stop_sign,
output [15:0] un_time
);

enum logic [1:0] {Halted,run,pause,Done} State,Next_state;

always_ff @ (posedge clk)
begin
	if(reset)
	State<=Halted;
	else
	State<=Next_state;
end

always_comb
begin
	Next_state=State;
	case(State)
		Halted:
			if(start_sign)
				Next_state=run;
		run:
			if (reset)
				Next_state=Halted;
//			else if (pause_sign)
//				Next_state=pause;
			else if (un_time==16'd5669)
				Next_state=Done;
//		pause:
//			if (reset)
//				Next_state=Halted;
//			else if(!pause_sign)
//				Next_state=run;

		endcase
	end

always_comb
begin
		stop_sign=0;
		case(State)
		Done:
		stop_sign=1;
		endcase
end
always_ff @ (posedge new_frame)
begin
	case(State)
		Halted:
			un_time=0;
		run:
			un_time<=un_time+1;
		pause:
			un_time<=un_time;
		Done:
			un_time<=5680;
	endcase
end


endmodule
