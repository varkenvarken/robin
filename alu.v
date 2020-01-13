/* robin, a SoC design for the IceBreaker board.
 *
 * alu.v : a 32 bit pure combinatorial alu
 *
 * Copyright 2019,2020 Michel Anders
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License. 
 */
 
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

	wire [32:0] add = {0, a + b};
	wire [32:0] adc = add + { 32'd0, carry_in};
	wire [32:0] sub = {0, a - b};
	wire [32:0] sbc = sub - { 32'd0, carry_in};
	wire [32:0] b_and = {0, a & b};
	wire [32:0] b_or  = {0, a | b};
	wire [32:0] b_xor = {0, a ^ b};
	wire [32:0] b_not = {0,~a    };
	wire [32:0] extend = {a[31],a};
	wire [32:0] min_a = -extend;
	wire [32:0] cmp = sub[31] ? 33'h1ffff_ffff : sub == 0 ? 0 : 1;
	wire [32:0] shiftl = {a[31:0],1'b0};
	wire [32:0] shiftr = {a[0],1'b0,a[31:1]};
	wire [31:0] mult_al_bl = a[15: 0] * b[15: 0];
	wire [31:0] mult_al_bh = a[15: 0] * b[31:16];
	wire [31:0] mult_ah_bl = a[31:16] * b[15: 0];
	wire [31:0] mult_ah_bh = a[31:16] * b[31:16];
	wire [63:0] mult64 = {32'b0,mult_al_bl} + {16'b0,mult_al_bh,16'b0} + {16'b0,mult_ah_bl,16'b0} + {mult_ah_bh,32'b0};

	wire [32:0] result;

	assign result = 
				op[4:0] == 0 ? add :
				op[4:0] == 1 ? adc :
				op[4:0] == 2 ? sub :
				op[4:0] == 3 ? sbc :

				op[4:0] == 4 ? b_or :
				op[4:0] == 5 ? b_and :
				op[4:0] == 6 ? b_not :
				op[4:0] == 7 ? b_xor :

				op[4:0] == 8 ? cmp :
				op[4:0] == 9 ? {1'b0, a} :

				op[4:0] == 12 ? shiftl :
				op[4:0] == 13 ? shiftr :

				op[4:0] == 16 ? {17'b0, mult_al_bl} :
				op[4:0] == 17 ? {1'b0, mult64[31:0]} :
				op[4:0] == 18 ? {1'b0, mult64[63:32]} :
				33'b0;

	assign c = result[31:0];
	assign carry_out = result[32];
	assign is_zero = (c == 0);
	assign is_negative = c[31];

endmodule
