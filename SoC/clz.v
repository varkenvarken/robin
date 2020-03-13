module clz(
	input [31:0] a,
	output [31:0] c
	);

	wire  [7:0] ai;
	wire  [15:0] z;

	genvar i;

	for(i=7; i>=0 ; i--) begin
		assign ai[i    ] = ~|a[i*4+3:i*4];
		assign  z[i*2+1] = ~(a[i*4+3]|a[i*4+2]);
		assign  z[i*2  ] = ~((~a[i*4+2] & a[i*4+1]) | a[i*4+3]);
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
