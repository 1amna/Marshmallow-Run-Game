//`timescale 1ns / 1ns // `timescale time_unit/time_precision

// I think I can remove the entire control block, and the top level module
// can just be the datapath...

module ground3(
	input clock,			// CLOCK_50
	input resetn,			// synchronous low reset
	input new_frame,		// signal for a new_frame from the master fsm
	input erase,			// signal from master fsm to erase
	input[2:0] speed,
	input new_level,			// current level
	output [8:0] x,			// x output
	output [7:0] y,			// y output
	output [2:0] colour,		// colour output
	output [439:0] state_out // state out
	);
	
	wire [7:0] random;
	
	// insantiate datapath
	ground_datapath d0(
		.clock(clock),
		.resetn(resetn),
		.new_frame(new_frame),
		.erase(erase),
		.speed(speed),
		.new_level(new_level),
		.random(random),
		.state_out(state_out),
		.x(x),
		.y(y),
		.colour(colour)
		);
	
	// instantiate lsfr
	lfsr l0(
		.Y(random),
		.clock(clock),
		.reset(resetn)
		);
	
endmodule

module ground_datapath(
	input clock,			// CLOCK_50
	input resetn,			// synchronous low reset
	input new_frame,		// signal for a new_frame from the master fsm
	input erase,			// signal from master fsm to erase
	input[2:0] speed,
	input[7:0] random,			// random number output from lsfr 
	input new_level,
	output [439:0] state_out,
	output reg [8:0] x,			// x output
	output reg [7:0] y,			// y output
	output reg [2:0] colour		// colour output
	);
	
	// y-coordinate at which the ground starts, measured from the top
	localparam
		screen_width = 9'b101101000, //360px across
		ground_level = 8'd240 - 8'd80, //80px from bottom of screen
		grass_level = 7'b0010100, 	//20px from ground origin
		lava_level = 7'b0101000; //40px from ground origin
	
	// colours
	localparam
		green = 3'b010,
		red = 3'b100,
		black = 3'b000,
		cyan = 3'b011;
		
	reg [6:0] max_frames;
	always @ (posedge clock)
	begin
		if (!resetn) begin
			max_frames <= 1'b0;
		end else if (speed == 3'd2) begin
			max_frames <= 7'd80;
		end else if (speed == 3'd3) begin
			max_frames <= 7'd70;
		end else if (speed == 3'd4) begin
			max_frames <= 7'd60;
		end else if (speed == 3'd5) begin
			max_frames <= 7'd55;
		end else if (speed == 3'd6) begin
			max_frames <= 7'd50;
		end else if (speed == 3'd7) begin
			max_frames <= 7'd45;
		end
	end
		
	reg [6:0] frames;
	always @ (posedge clock)
	begin
		if (!resetn) begin
			frames <= 1'b0;
		end else if (new_frame) begin
			frames <= frames + 1'b1;
		end else if (frames >= max_frames) begin
			frames <= 1'b0;
		end
	end
	
	reg [6:0] a, b, c;
	always @ (posedge clock)
	begin
		if (!resetn) begin
			a <= 7'd230;
			b <= a - 7'd102;
			c <= b - 7'd64;
		end else if (new_level) begin
			a <= a * 1'b1;
			b <= b * 1'b1;
			c <= c * 1'b1;
		end
	end
	
	reg [5:0] lava_width;
	always @ (posedge clock)
	begin
		if (!resetn) begin
			lava_width <= 6'd40;
		end else if (random > a) begin
			lava_width <= 6'd40;
		end else if (random > b) begin
			lava_width <= 6'd30;
		end else if (random > c) begin
			lava_width <= 6'd20;
		end else begin
			lava_width <= 6'd10;
		end
	end
			

	// current state of the ground
	reg[439:0] state;
	// shifting to the left
	// shift must be connected to FrameCounter
    always@(posedge clock) begin
        if(!resetn) begin
            state <= 439'b0;
        end
        else if (new_frame) begin
            state <= state << speed;
 			if (frames == max_frames - 1'b1) begin
 				if (random % 2 == 1'b0)
					state[79:0] <= state[79:0] + ((2'd2 ** 7'd60) - 1'b1);
			end
		end
    end
	
	assign state_out = state;
	
	// counter
	reg[15:0] q;
	wire[15:0] max;
	assign max = 16'b1011010001010000;
	always @(posedge clock)
	begin
		if (resetn == 1'b0)
			q <= 1'b0;
		else if (q[6:0] == 7'b1010000) begin
			q[15:7] <= q[15:7] + 1'b1;
			q[6:0] <= 1'b0;
		end
		else if (q == max) begin
			q <= 1'b0;
			end
		else
			q <= q + 1'b1;
	end
	wire[8:0] x_add;
	wire[7:0] y_add;
	assign x_add = q[15:7];
	assign y_add = 8'b0 + q[6:0];
	
    // output result register
    always@(posedge clock) begin
		// reset
        if(!resetn) begin
            x <= 8'b0; 
			y <= 7'b0;
			colour <= 3'b0;
        end
		// erase
//		else if(erase) begin
//			x <= screen_width - x_add;
//			y <= ground_level + y_add;
//			colour <= 3'b111;
//		end
		// draw
        else 
			if (state[7'd80 + x_add] == 1'b0) begin
				if (y_add <= grass_level) begin
					x <= screen_width - x_add;
					y <= ground_level + y_add;
					colour <= green;
				end
				else begin
					x <= screen_width - x_add;
					y <= ground_level + y_add;
					colour <= black;
				end
			end
			else if (state[7'd80 + x_add] == 1'b1) begin
				if (y_add <= lava_level) begin
					x <= screen_width - x_add;
					y <= ground_level + y_add;
					colour <= cyan;
				end
				else begin
					x <= screen_width - x_add;
					y <= ground_level + y_add;
					colour <= red;
				end
			end
    end

endmodule


module lfsr (clock, reset, Y);

	input clock, reset;
	output [7:0] Y;

	integer N;
	parameter [7:0] Taps = 8'b10001110;
	reg Bits0_6_Zero, Feedback;

	reg [7:0] LFSR_Reg, Next_LFSR_Reg;

	always@(posedge clock or negedge reset)
	  begin:  LFSR_Register
		if (!reset)
		  LFSR_Reg <= 8'b0;
		else LFSR_Reg <= #1 Next_LFSR_Reg;
	  end

	always@(LFSR_Reg)
	  begin: LFSR_Feedback
		Bits0_6_Zero = ~| LFSR_Reg[6:0];
		Feedback = LFSR_Reg[7] ^ Bits0_6_Zero;
		for (N=7; N>=1; N=N-1)
		  if (Taps[N-1] == 1)
			Next_LFSR_Reg[N] = LFSR_Reg[N-1] ^ Feedback;
		  else
			Next_LFSR_Reg[N] = LFSR_Reg[N-1];
		Next_LFSR_Reg[0] = Feedback;
	  end

	assign Y = LFSR_Reg;

endmodule