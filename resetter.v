`timescale 1ns / 1ns // `timescale time_unit/time_precision	

module resetter(
	input clock,
	input resetn,
	output reg [8:0] x,
	output reg [7:0] y,
	output reg [2:0] colour
	);
	
	localparam cyan = 3'b011;
	
	// counter
	reg[16:0] q;
	wire [16:0] max = {9'd360, 8'd240}; // counts to a maximum of 360 x 240, i.e. entire screen
	always @(posedge clock)
	begin
		if (resetn == 1'b0) begin
			q <= 1'b0;
		end else if (q[6:0] == 8'd240) begin
			q[16:8] <= q[16:8] + 1'b1;
			q[7:0] <= 1'b0;
		end else if (q == max) begin
			q <= 1'b0;
		end else begin
			q <= q + 1'b1;
		end
	end
	wire[8:0] x_add;
	wire[7:0] y_add;
	assign x_add = q[16:8];
	assign y_add = q[7:0];
	
	// output result register
    always@(posedge clock) begin
		// reset
        if(!resetn) begin
            x <= 8'b0; 
			y <= 7'b0;
			colour <= 3'b0;
        end else begin
			x <= x_add;
			y <= y_add;
			colour <= cyan;
		end
	end
	
endmodule