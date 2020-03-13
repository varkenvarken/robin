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

	nlc nlc7(a[31:28], ai[7], z[15:14]);
	nlc nlc6(a[27:24], ai[6], z[13:12]);
	nlc nlc5(a[23:20], ai[5], z[11:10]);
	nlc nlc4(a[19:16], ai[4], z[ 9: 8]);
	nlc nlc3(a[15:12], ai[3], z[ 7: 6]);
	nlc nlc2(a[11: 8], ai[2], z[ 5: 4]);
	nlc nlc1(a[ 7: 4], ai[1], z[ 3: 2]);
	nlc nlc0(a[ 3: 0], ai[0], z[ 1: 0]);

	wire q = &(ai); // true if all nibbles are all zeros
	wire [5:0] y;

	assign y = 	ai[7] ? (			// leftmost nibble all zeros?
				ai[6] ? (
				ai[5] ? (
				ai[4] ? (
				ai[3] ? (
				ai[2] ? (
				ai[1] ? (
				ai[0] ? ( q ? 6'b100000 : 6'b000000
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
