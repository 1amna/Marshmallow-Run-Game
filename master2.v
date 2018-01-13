`timescale 1ns / 1ns // `timescale time_unit/time_precision

// I can probably just merge these into the same module, it'll
// actually be shorter. call it master2.v

module master2(
	input clock,
	input resetn,
	output new_frame_out,
	output erase,
	output select,
	output plot,
	output move,
	output reset_screen
	);
	
	wire change0, change1, change2, change3, change4;
	assign move = change2;
	
	wire new_frame;
	assign new_frame_out = new_frame;
	
	//initialize frame counter
	frame_counter f0(
		.clock(clock),
		.resetn(resetn),
		.new_frame(new_frame),
		.change0(change0),
		.change1(change1),
		.change2(change2),
		.change3(change3),
		.change4(change4)
		);
	
	// initialize fsm
	control c0(
		.clock(clock),
		.resetn(resetn),
		.new_frame(new_frame),
		.change0(change0),
		.change1(change1),
		.change2(change2),
		.change3(change3),
		.change4(change4),
		.erase(erase),
		.select(select),
		.plot(plot),
		.reset_screen(reset_screen)
		);

endmodule

module control(
	input clock,				// CLOCK_50
	input resetn,				// synchronous-low reset
	input new_frame,			// ...
	input change0,
	input change1,			// input from frame_counter that half a frame has passed
	input change2,		// ...
	input change3,		// ...
	input change4,
	output reg erase,		// signal to datapath to erase (draw background colour)
	output reg select,
	output reg plot,
	output reg reset_screen
	);
	
	reg [2:0] current_state, next_state;
    
    localparam  ERASE_GROUND  = 3'd0,
				ERASE_SPRITE = 3'd1,
				DRAW_GROUND = 3'd2,
                DRAW_SPRITE   = 3'd3,
				START_WAIT = 3'd4,
				END_WAIT = 3'd5,
				RESET = 3'd6;
				
    always@(*)
    begin: state_table 
            case (current_state)
				RESET: next_state = new_frame ? START_WAIT : RESET;
				START_WAIT: next_state = change0 ? ERASE_GROUND : START_WAIT;
                ERASE_GROUND: next_state = change1 ? ERASE_SPRITE : ERASE_GROUND;
				ERASE_SPRITE: next_state = change2 ? DRAW_GROUND : ERASE_SPRITE;
                DRAW_GROUND: next_state = change3 ? DRAW_SPRITE : DRAW_GROUND;
				DRAW_SPRITE: next_state = change4 ? END_WAIT : DRAW_SPRITE;
				END_WAIT: next_state = new_frame ? START_WAIT : END_WAIT; // wait until a new frame occurs
            default:     next_state = RESET;
        endcase
    end
	
	// Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        erase = 1'b0;
		select = 1'b0;
		plot = 1'b0;
		reset_screen = 1'b0;
        case (current_state)
			RESET: begin
				reset_screen = 1'b1;
				erase = 1'b1;
				select = 1'b0;
				plot = 1'b1;
                end
            ERASE_GROUND: begin
                erase = 1'b1;
				select = 1'b0;
				plot = 1'b1;
                end
            ERASE_SPRITE: begin
                erase = 1'b1;
				select = 1'b1;
				plot = 1'b1;
                end
			DRAW_GROUND: begin
				erase = 1'b0;
				select = 1'b0;
				plot = 1'b1;
				end
			DRAW_SPRITE: begin
				erase = 1'b0;
				select = 1'b1;
				plot = 1'b1;
				end
			START_WAIT: begin
				plot = 1'b0;
				end
			END_WAIT: begin
				plot = 1'b0;
				end
        endcase
    end // enable_signals
	
	// current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(!resetn)
            current_state <= RESET;
        else
            current_state <= next_state;
    end // state_FFS
	
endmodule

module frame_counter(
	input clock,
	input resetn,
	output new_frame,
	output change0,
	output change1,
	output change2,
	output change3,
	output change4
	);
	
/*  	localparam
		init = 20'd833333,
		three_q = 20'd624999,
		half = 20'd416666,
		quarter = 20'd208333; */
		
// better to use these, buffered on either side

   	localparam
		init = 20'd833333,
		mark0 = 20'd800000, //12
		mark1 = 20'd700000, //9
		mark2 = 20'd600000, //7
		mark3 = 20'd500000, //5
		mark4 = 20'd400000; //3


/*  	localparam
		init = 20'd833333,
		mark0 = 20'd350000, //12
		mark1 = 20'd32000, //9
		mark2 = 20'd31000, //7
		mark3 = 20'd2000, //5
		mark4 = 20'd1000; //3 */

		
/* 		localparam
		init = 9'd4, //15
		mark0 = 9'd3, //12
		mark1 = 9'd2, //9
		mark2 = 9'd2, //7
		mark3 = 9'd1, //5
		mark4 = 9'd0; //3 */
	
	reg[20:0] q;
	
	always @(posedge clock)
	begin
		if (resetn == 1'b0)
			q <= init - 1'b1;
		else if (q == 1'b0)
			q <= init - 1'b1;
		else
			q <= q - 1'b1;
	end
	
	assign change0 = (q == mark0) ? 1'b1 : 1'b0;
	assign change1 = (q == mark1) ? 1'b1 : 1'b0;
	assign change2 = (q == mark2) ? 1'b1 : 1'b0;
	assign change3 = (q == mark3) ? 1'b1 : 1'b0;
	assign change4 = (q == mark4) ? 1'b1 : 1'b0;
	assign new_frame = (q == 20'b0) ? 1'b1 : 1'b0;
	
	
endmodule