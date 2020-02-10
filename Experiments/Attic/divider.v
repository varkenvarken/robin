/* robin, a SoC design for the IceBreaker board.
 *
 * divider.v : a 32 bit integer division module
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
 
 module divider(
    input clk,
    input reset,
	input [31:0] a,
	input [31:0] b,
	input go,
	input divs,
	input remainder,
	output [31:0] c,
	output is_zero,
	output is_negative,
	output reg available
	);

	localparam DIV_SHIFTL    = 2'd0;
	localparam DIV_SUBTRACT  = 2'd1;
	localparam DIV_AVAILABLE = 2'd2;
	localparam DIV_DONE      = 2'd3;
	reg [1:0] step;

	reg [32:0] dividend;
	reg [32:0] divisor;
	reg [32:0] quotient, quotient_part;
	wire overshoot = divisor > dividend;
	wire division_by_zero = (b == 0);
	wire sign = a[31] ^ b[31];
	wire [31:0] result = remainder ? dividend[31:0] : quotient[31:0];

	always @(posedge clk) begin
		if(go) begin
			step <= division_by_zero ? DIV_AVAILABLE : DIV_SHIFTL;
			available <= 0;
			dividend  <= divs ? {2'b0, a[30:0]} : {1'b0, a}; // have to add negation for a and b if they are negative!
			divisor   <= divs ? {2'b0, b[30:0]} : {1'b0, b};
			quotient  <= 0;
			quotient_part <= 1;
		end else
			case(step)
				DIV_SHIFTL	: 	begin
									if(~overshoot) begin
										divisor <= divisor << 1;
										quotient_part <= quotient_part << 1;
									end else begin
										divisor <= divisor >> 1;
										quotient_part <= quotient_part >> 1;
										step <= DIV_SUBTRACT;
									end
								end
				DIV_SUBTRACT:	begin
									if(quotient_part == 0)
										step <= DIV_AVAILABLE;
									else begin
										if(~overshoot) begin
											dividend <= dividend - divisor;
											quotient <= quotient | quotient_part;
										end 
										divisor <= divisor >> 1;
										quotient_part <= quotient_part >> 1;
									end
								end
				DIV_AVAILABLE:	begin
									step <= DIV_DONE;
									available <= 1;
								end
				default		: 	available <= 0;
			endcase
	end

	assign c = divs ? {sign, result[30:0]} : result[31:0];
	assign is_zero = (c == 0);
	assign is_negative = c[31];

endmodule
