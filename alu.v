module alu(
	input [31:0] a,
	input [31:0] b,
	input carry_in,
	input [7:0] op,
	output [31:0] c,
	output carry_out,
	output is_zero,
	output is_negative
	);

	wire [32:0] add = {0, a} + {0, b};
	wire [32:0] adc = add + { 32'd0, carry_in};
	wire [32:0] sub = {0, a} - {0, b};
	wire [32:0] sbc = sub - { 32'd0, carry_in};
	wire [32:0] b_and = {0, a & b};
	wire [32:0] b_or  = {0, a | b};
	wire [32:0] b_xor = {0, a ^ b};
	wire [32:0] b_not = {0,~a    };
	wire [32:0] extend = {a[31],a};
	wire [32:0] min_a = -extend;
	wire [32:0] cmp = sub[32] ? 33'h1ffff_ffff : sub == 0 ? 0 : 1;
	wire [32:0] shiftl = {a[31:0],1'b0};
	wire [32:0] shiftr = {a[0],1'b0,a[31:1]};

	wire [32:0] result;

	always @(*) begin
		result= op == 0 ? add :
				op == 1 ? adc :
				op == 2 ? sub :
				op == 3 ? sbc :

				op == 4 ? b_or :
				op == 5 ? b_and :
				op == 6 ? b_not :
				op == 7 ? b_xor :

				op == 8 ? cmp :

				op == 12 ? shiftl :
				op == 13 ? shiftr :
				33'b0;
	end

	assign c = result[31:0];
	assign carry_out = result[32];
	assign is_zero = (c == 0);
	assign is_negative = c[31];

endmodule
