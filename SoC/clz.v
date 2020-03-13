module nlc(
	input  [3:0] x,
	output       a,		// true if all zero
	output [1:0] z
	);

	assign a    = ~|x;
	assign z[1] = ~(x[3]|x[2]);
	assign z[0] = ~((~x[2] & x[1]) | x[3]);
	
endmodule

module clz(
	input [31:0] a,
	output [31:0] c
	);

	wire  [7:0] ai;
	wire  [15:0] z;

	genvar i;

	for(i=7; i>=0 ; i--) begin
		nlc nlc(a[i*4+3:i*4], ai[i], z[i*2+1:i*2]);
	end

	wire [5:0] y;

	assign y = 	ai[7] ? (			// leftmost nibble all zeros?
				ai[6] ? (
				ai[5] ? (
				ai[4] ? (
				ai[3] ? (
				ai[2] ? (
				ai[1] ? (
				ai[0] ? ( 6'b100000
						) : {4'b0111, z[ 1: 0]}
						) : {4'b0110, z[ 3: 2]}
						) : {4'b0101, z[ 5: 4]}
						) : {4'b0100, z[ 7: 6]}
						) : {4'b0011, z[ 9: 8]}
						) : {4'b0010, z[11:10]}
						) : {4'b0001, z[13:12]}
						) : {4'b0000, z[15:14]};

	assign c = {26'b0, y};
endmodule
