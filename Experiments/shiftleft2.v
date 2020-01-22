module shiftleft2(
	input [31:0] a,
	input [31:0] b,
	output [31:0] c
);

	wire [4:0] nshift = b[4:0];
	wire shiftlo   = ~nshift[4];	// true if shifting < 16 bits
	wire shifthi   =  nshift[4];	// true if shifting >= 16 bits

	// determine power of two
	wire shiftla0  = nshift[3:0]  == 4'd0;	// 2^0 = 1
	wire shiftla1  = nshift[3:0]  == 4'd1;	// 2^1 = 2
	wire shiftla2  = nshift[3:0]  == 4'd2;	// 2^2 = 3
	wire shiftla3  = nshift[3:0]  == 4'd3;	// ... etc 
	wire shiftla4  = nshift[3:0]  == 4'd4;
	wire shiftla5  = nshift[3:0]  == 4'd5;
	wire shiftla6  = nshift[3:0]  == 4'd6;
	wire shiftla7  = nshift[3:0]  == 4'd7;
	wire shiftla8  = nshift[3:0]  == 4'd8;
	wire shiftla9  = nshift[3:0]  == 4'd9;
	wire shiftla10 = nshift[3:0]  == 4'd10;
	wire shiftla11 = nshift[3:0]  == 4'd11;
	wire shiftla12 = nshift[3:0]  == 4'd12;
	wire shiftla13 = nshift[3:0]  == 4'd13;
	wire shiftla14 = nshift[3:0]  == 4'd14;
	wire shiftla15 = nshift[3:0]  == 4'd15;
	// combine into 16 bit word
	wire [15:0] shiftla16 = {shiftla15,shiftla14,shiftla13,shiftla12,
							 shiftla11,shiftla10,shiftla9 ,shiftla8 ,
							 shiftla7 ,shiftla6 ,shiftla5 ,shiftla4 ,
							 shiftla3 ,shiftla2 ,shiftla1 ,shiftla0};

	// 4 16x16 bit partial multiplications
	// the multiplier is either the b operand or a power of two for a shift
	// note that b[31:16] for shift operations [31-0] is always zero
	// so when shiftlo is true al_bh and ah_bh still result in zero
	// the same is not true the other way around hence the extra shiftq check
	// note that the behavior is undefined for shifts > 31
	wire [31:0] mult_al_bl = a[15: 0] * (shiftlo ? shiftla16 : 16'b0);
	wire [31:0] mult_al_bh = a[15: 0] * (shifthi ? shiftla16 : b[31:16]);
	wire [31:0] mult_ah_bl = a[31:16] * (shiftlo ? shiftla16 : 16'b0);
	wire [31:0] mult_ah_bh = a[31:16] * (shifthi ? shiftla16 : b[31:16]);
	// combine the intermediate results into a 64 bit result
	wire [63:0] mult64 = {32'b0,mult_al_bl} + {16'b0,mult_al_bh,16'b0}
				       + {16'b0,mult_ah_bl,16'b0} + {mult_ah_bh,32'b0};

	assign c = mult64[31:0];

endmodule
