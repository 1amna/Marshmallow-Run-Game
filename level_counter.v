`timescale 1ns / 1ns // `timescale time_unit/time_precision

module level_counter(
	input clock,
	input resetn,
	input [11:0] score,
	output reg [2:0] level,
	output reg [2:0] speed
	);
	
	always @ (posedge clock)
	begin
		if (!resetn) begin
			level <= 3'd1;
			speed <= 3'd2;
		end else if (score < 7) begin
			level <= 3'd1;
			speed <= 3'd2;
		end else if (score < 14) begin
			level <= 3'd2;
			speed <= 3'd3;
		end else if (score < 21) begin
			level <= 3'd3;
			speed <= 3'd4;
		end else if (score < 28) begin
			level <= 3'd4;
			speed <= 3'd5;
		end else if (score < 35) begin
			level <= 3'd5;
			speed <= 3'd6;
		end else if (score >= 35) begin
			level <= 3'd6;
			speed <= 3'd7;
		end
	end
		
	
endmodule