`timescale 1ns / 1ns // `timescale time_unit/time_precision	

// master handles frame timing, erasing and drawing states
// sprite handles sprite animation, jumping/falling logic
// ground handles ground animation, generation, shifting logic

// move mux2to1 to a separate file, it's neater

// only outputs necessary are x, y, colour, plot, those get
// passed to the vga in a higher module

module top3(

	// control inputs
	input clock,
	input resetn,
	input jump,
	output [8:0] x_out,
	output [7:0] y_out,
	output [2:0] c_out,
	output plot,
	output [2:0] level_out,
	output [11:0] score_out
	);
	
	wire kill;
	
	wire [19:0] sprite_out;
	wire [19:0] ground_out;
	wire [19:0] resetter_out;
	wire [19:0] mux0_out;
	wire [19:0] mux1_out;
	
	assign x_out = mux1_out[19:11];
	assign y_out = mux1_out[10:3];
	assign c_out = mux1_out[2:0];
	
	wire new_frame, erase, select, move, reset_screen, new_level;
	assign new_level = 1'b0;
	
	wire [11:0] score;
	wire [2:0] speed;
	wire [2:0] level;
	assign score_out = score;
	assign level_out = level;
	
	wire [439:0] state;
	wire [19:0] ground_under_sprite = state[399:379];
	wire [6:0] ground_under_feet = state[392:386];
	wire rightmost_ground = state[379];
	wire [39:0] jumped_ground = state[439:392];
	
	wire [7:0] y0;
	
	//master
	master2 m0(
		.clock(clock),
		.resetn(resetn),
		.new_frame_out(new_frame),
		.erase(erase),
		.select(select),
		.move(move),
		.plot(plot),
		.reset_screen(reset_screen)
		);
	
	//ground3
	ground3 g0(
		.clock(clock),
		.resetn(resetn),
		.new_frame(new_frame && ~kill),
		.erase(erase),
		.speed(speed),
		.new_level(new_level),
		.x(ground_out[19:11]),
		.y(ground_out[10:3]),
		.colour(ground_out[2:0]),
		.state_out(state)
		);
		
	//sprite2
	sprite4 s0(
		.clock(clock),
		.resetn(resetn),
		.move(move && ~kill),
		.jump(jump),
		.ground_under_sprite(ground_under_sprite),
		.ground_under_feet(ground_under_feet),
		.rightmost_ground(rightmost_ground),
		.jumped_ground(jumped_ground),
		.erase(erase),
		.x(sprite_out[19:11]),
		.y(sprite_out[10:3]),
		.colour(sprite_out[2:0]),
		.kill(kill),
		.y0_out(y0),
		.score(score)
		);
		
	//resetter
	resetter r0(
		.clock(clock),
		.resetn(resetn),
		.x(resetter_out[19:11]),
		.y(resetter_out[10:3]),
		.colour(resetter_out[2:0])
		);
		
	//level_counter
	level_counter lc0(
		.clock(clock),
		.resetn(resetn),
		.score(score),
		.level(level),
		.speed(speed)
		);
		
	//mux 0 : ground or sprite
	mux2to1 mux0(
		.x(ground_out),
		.y(sprite_out),
		.s(select),
		.m(mux0_out)
		);
		
	//mux 1 : resetter or ground/sprite
	mux2to1 mux1(
		.x(mux0_out),
		.y(resetter_out),
		.s(reset_screen),
		.m(mux1_out)
		);
	
endmodule

module mux2to1(x, y, s, m);
    input [19:0] x; //selected when s is 0
    input [19:0] y; //selected when s is 1
    input s; //select signal
    output [19:0] m; //output
  
    assign m = s ? y : x;

endmodule