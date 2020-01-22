module shiftleft(
	input [31:0] a,
	input [31:0] b,
	output [31:0] c
);

	wire [63:0] tmp = { a, 32'b0 };
	assign c = tmp[63 - b[5:0] -:32]; 
endmodule
