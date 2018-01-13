/* 
TO DO:
actual feet?
lava blend
legs cycle faster at faster speed
decreasing likelihood of gap - use mod and hardcode probabilities

*/

module project(

	// control inputs
	input CLOCK_50,
	input [3:0] KEY,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	
	
	// vga outputs
	output			VGA_CLK,   				//	VGA Clock
	output			VGA_HS,					//	VGA H_SYNC
	output			VGA_VS,					//	VGA V_SYNC
	output			VGA_BLANK_N,				//	VGA BLANK
	output			VGA_SYNC_N,				//	VGA SYNC
	output	[9:0]	VGA_R,   				//	VGA Red[9:0]
	output	[9:0]	VGA_G,	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B  				//	VGA Blue[9:0]
	
	);
	
	wire [8:0] x;
	wire [7:0] y;
	wire [2:0] colour;
	wire plot;
	
	wire [11:0] score;
	wire [2:0] level;
	
	// instantiate top
	top3 t0(
		.clock(CLOCK_50),
		.resetn(KEY[0]),
		.jump(~KEY[1]),
		.x_out(x),
		.y_out(y),
		.c_out(colour),
		.plot(plot),
		.level_out(level),
		.score_out(score)
		);
	
	//vga
	vga_adapter VGA(
		.resetn(KEY[0]),
		.clock(CLOCK_50),
		.colour(colour),
		.x(x),
		.y(y),
		.plot(plot),
		/* Signals for the DAC to drive the monitor. */
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK(VGA_BLANK_N),
		.VGA_SYNC(VGA_SYNC_N),
		.VGA_CLK(VGA_CLK));
	defparam VGA.RESOLUTION = "320x240";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "black.mif";
	
	// score
	score s0(
		.clock(CLOCK_50),
		.resetn(KEY[0]),
		.score(score),
		.level(level),
		.out0(HEX0),
		.out1(HEX1),
		.out2(HEX2),
		.out3(HEX3),
		.out4(HEX4),
		.out5(HEX5)
		);
	
endmodule