/* robin, a SoC design for the IceBreaker board.
 *
 * cpuv2.v : a risc cpu
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

module cpuv2(clk, mem_data_out, mem_data_in, mem_raddr, mem_waddr, mem_write, mem_ready, start_address, reset, halt, halted);
	parameter addr_width = 9;
	input clk;
	input [7:0] mem_data_out;		// from memory to cpu
	output reg [7:0] mem_data_in;	// from cpu to memory
	output reg [addr_width-1:0] mem_raddr;
	output reg [addr_width-1:0] mem_waddr;
	output reg mem_write;
	input mem_ready;
	input [addr_width-1:0] start_address;
	input reset;
	input halt;
	output reg halted;

	// general registers
	reg [31:0] r[0:15];
	reg [31:0] temp;

	// special registers
	reg [15:0] instruction;

	reg [addr_width-1:0] mem_waddr_next;

	// alu
	wire [31:0] alu_a = r[R1];
	wire [31:0] alu_b = r[R0];
	wire [7:0] alu_op = r[13][7:0];
	wire [31:0] alu_c;
	wire alu_is_zero;
	wire alu_is_negative;

	alu alu0(
		.a(alu_a),
		.b(alu_b),
		.op(alu_op),
		.c(alu_c),
		.is_zero(alu_is_zero),
		.is_negative(alu_is_negative)
	);

	// divider
	wire [31:0] div_a = r[R1];
	wire [31:0] div_b = r[R0];
	wire [31:0] div_c;
	wire div_divs = alu_op[0];
	wire remainder = alu_op[1];
	wire div_is_zero;
	wire div_is_negative;
	wire div_is_available;

	divider div0(
		.clk(clk),
		.reset(reset),
		.a(div_a),
		.b(div_b),
		.go(div_go),
		.divs(div_divs),
		.remainder(remainder),
		.c(div_c),
		.is_zero(div_is_zero),
		.is_negative(div_is_negative),
		.available(div_is_available)
	);

	// state machine
	reg [3:0] state;
	localparam FETCH1		= 0;
	localparam FETCH2		= 1;
	localparam FETCH3		= 2;
	localparam FETCH4		= 3;
	localparam FETCH5		= 4;
	localparam FETCH6		= 5;
	localparam DECODE		= 6;
	localparam EXEC1		= 7;
	localparam EXEC2		= 8;
	localparam EXEC3		= 9;
	localparam EXEC4		= 10;
	localparam EXEC5		= 11;
	localparam EXEC6		= 12;
	localparam EXEC7		= 13;
	localparam EXEC8		= 14;
	localparam HALT			= 15;

	wire [addr_width-1:0] ip = r[15][addr_width-1:0]; // the addressable bits of the program counter

	reg pop;
	reg alu, div, div_go;
	reg loadb3, loadb2, loadb1, loadb0;
	reg branch, movereg;
	reg storb3, storb2, storb1, storb0;

	wire [3:0] cmd = instruction[15:12]; // main opcode
	wire [3:0] R2  = instruction[11: 8]; // destination register
	wire [3:0] R1  = instruction[ 7: 4]; // source register 1
	wire [3:0] R0  = instruction[ 3: 0]; // source register 0
	wire [7:0] immediate = instruction[7:0];
	wire haltinstruction = &instruction; // all ones
	wire [31:0] r1_offset = r[R1] + {{26{R0[3]}},R0,2'b00};  // sign extended offset * 4

	// branch logic
	wire [31:0] relative = {{16{temp[31]}},temp[30:16]}; // 16 bit sign extended to 32; those 16 bits will be in the upper half of temp!
	wire [31:0] branchtarget = r[15] + relative;
	wire takebranch = ((r[13][31:29] & instruction[10:8]) == ({3{instruction[11]}} & instruction[10:8]));

	wire [31:0] sumr1r0 = r[R1] + r[R0];
	wire [addr_width-1:0] sumr1r0_addr = sumr1r0[addr_width-1:0];

	localparam CMD_MOVEP   =  0;
	localparam CMD_ALU     =  2;
	localparam CMD_MOVER   =  3;
	localparam CMD_LOADB   =  4;
	localparam CMD_LOADL   =  6;
	localparam CMD_LOADIL  =  7;
	localparam CMD_STORB   =  8;
	localparam CMD_STORL   = 10;
	localparam CMD_LOADI   = 12;
	localparam CMD_BRANCH  = 13;
	localparam CMD_JUMP    = 14;
	localparam CMD_SPECIAL = 15;

	localparam SPECIAL_MARK		=  0;
	localparam SPECIAL_POP		=  1;
	localparam SPECIAL_PUSH		=  2;
	localparam SPECIAL_SETEQ	=  8;
	localparam SPECIAL_SETNE	=  9;
	localparam SPECIAL_SETMIN	=  12;
	localparam SPECIAL_SETPOS	=  13;
	localparam SPECIAL_HALT		=  15;

	always @(posedge clk) begin
		mem_write <= 0;
		if(reset) begin
			r[15] <= start_address;
			halted <= 0;
			state <= FETCH1;
			instruction <= 0;
		end else
		if(halt | haltinstruction) begin
			state <= HALT;
			instruction <= 0; // this will clear haltinstruction
		end else
		case(state) // parallel_case
			FETCH1	:	begin
							r[0] <= 0;
							r[1] <= 1;
							r[13][31] <= 1; // force the always on bit
							mem_raddr <= ip;
							state <= halted ? FETCH1 : FETCH2;
						end
			FETCH2	:	state <= FETCH3;
			FETCH3	:	begin
							instruction[15:8] <= mem_data_out;
							r[15] <= r[15] + 1;
							state <= FETCH4;
						end
			FETCH4	:	begin
							mem_raddr <= ip;
							state <= FETCH5;
						end
			FETCH5	:	state <= FETCH6;
			FETCH6	:	begin
							instruction[7:0] <= mem_data_out;
							r[15] <= r[15] + 1;
							div_go <= 0;
							state <= DECODE;
							alu <= 0;
							div <= 0;
							pop <= 0;
							loadb3 <= 0;
							loadb2 <= 0;
							loadb1 <= 0;
							loadb0 <= 0;
							branch <= 0;
							movereg <= 0;
							storb3 <= 0;
							storb2 <= 0;
							storb1 <= 0;
							storb0 <= 0;
						end
			DECODE	:	begin
							state <= EXEC1;
							case(cmd)
								CMD_MOVEP:	movereg <= 1;
								CMD_ALU:	begin
												if(alu_op[5]) begin 
													div_go <= 1; // start the divider module if we have a divider operation
													div <= 1;
												end	else
													alu <= 1;
											end
								CMD_MOVER:	begin
												r[R2] <= r1_offset;
												state <= FETCH1;
											end
								CMD_LOADB:	begin
												loadb3 <= 1;
												mem_raddr <= sumr1r0_addr;
											end
								CMD_LOADL:	begin
												loadb3 <= 1;
												loadb2 <= 1;
												loadb1 <= 1;
												loadb0 <= 1;
												mem_raddr <= sumr1r0_addr;
											end
								CMD_LOADIL: begin
												loadb3 <= 1;
												loadb2 <= 1;
												loadb1 <= 1;
												loadb0 <= 1;
												mem_raddr <= r[15];
												r[15] <= r[15] + 4;
											end
								CMD_STORB:	begin
												storb3 <= 1;
												mem_waddr <= sumr1r0_addr;
											end
								CMD_STORL:	begin
												storb3 <= 1;
												storb2 <= 1;
												storb1 <= 1;
												storb0 <= 1;
												mem_waddr <= sumr1r0_addr;
											end
								CMD_LOADI:	begin
												r[R2][7:0] <= immediate;
												state <= FETCH1;
											end
								CMD_BRANCH:	begin
												branch <= 1;
												loadb3 <= 1;
												loadb2 <= 1;
												mem_raddr <= r[15];
												r[15] <= r[15] + 2;
											end
								CMD_JUMP:	begin
												r[R2] <= r[15];
												r[15] <= sumr1r0;
												state <= FETCH1;
											end
								CMD_SPECIAL:begin
												state <= EXEC1;
												case(immediate)
													SPECIAL_POP:	begin
																		mem_raddr <= r[14];
																		loadb3 <= 1;
																		loadb2 <= 1;
																		loadb1 <= 1;
																		loadb0 <= 1;
																		pop <= 1;
																	end
													SPECIAL_PUSH:	begin
																		r[14] <= r[14] - 4;
																		mem_waddr <= r[14] - 4;
																		storb3 <= 1;
																		storb2 <= 1;
																		storb1 <= 1;
																		storb0 <= 1;
																	end
													SPECIAL_SETEQ:	r[R2] <= {31'b0,  r[13][29]};
													SPECIAL_SETNE:	r[R2] <= {31'b0, ~r[13][29]};
													SPECIAL_SETMIN:	r[R2] <= {31'b0,  r[13][30]};
													SPECIAL_SETPOS:	r[R2] <= {31'b0, ~r[13][30]};
													default: state <= FETCH1;
												endcase
											end
								default: state <= FETCH1;
							endcase
						end
			EXEC1	:	begin
							div_go <= 0; // flag down the divider module again so that it is not reset forever
							state <= EXEC2;
							if (movereg) begin
								r[R2] <= sumr1r0;
								state <= FETCH1;
							end
							if (alu) begin
								r[R2] <= alu_c;
								r[13][29] <= alu_is_zero;
								r[13][30] <= alu_is_negative;
								state <= FETCH1;
							end
							if (div) begin // a divider operation (multiple cycles)
								if(div_is_available) begin
									r[R2] <= div_c;
									r[13][29] <= div_is_zero;
									r[13][30] <= div_is_negative;
									state <= FETCH1;
								end else begin
									state <= EXEC1; 
								end
							end
							if(storb3) mem_data_in <= storb2 ? r[R2][31:24] : r[R2][7:0] ; // first mem_waddr is set in DECODE step already
						end
			EXEC2	:	begin
							state <= FETCH1;
							if(loadb3) begin
								temp[31:24] <= mem_data_out;
								mem_raddr <= mem_raddr + 1;
								state <= EXEC3;
							end
							if(storb3) begin
								mem_write <= 1;
								state <= EXEC3;
							end
							if(pop) r[14] <= r[14] + 4; // no need to set state because loadb3 will also have been set
						end
			EXEC3	:	begin
							state <= FETCH1;
							if(loadb3 & ~loadb2) r[R2][7:0] <= temp[31:24];
							if(loadb2) state <= EXEC4;
							if(storb2) begin
								mem_waddr <= mem_waddr + 1;
								mem_data_in <= r[R2][23:16];
								state <= EXEC4;
							end
							if(storb3 & ~storb2) state <= FETCH1;
						end
			EXEC4	:	begin
							state <= FETCH1;
							if(loadb2) begin
								temp[23:16] <= mem_data_out;
								mem_raddr <= mem_raddr + 1;
								state <= EXEC5;
							end
							if(storb2) begin
								mem_write <= 1;
								state <= EXEC5;
							end
						end
			EXEC5	:	begin
							state <= FETCH1;
							if(loadb1|branch) state <= EXEC6;
							if(storb1) begin
								mem_waddr <= mem_waddr + 1;
								mem_data_in <= r[R2][15:8];
								state <= EXEC6;
							end
						end
			EXEC6	:	begin
							state <= FETCH1;
							if(branch & takebranch) r[15] <= branchtarget; // branchtarget refers to upper half of temp so should be ready
							if(loadb1) begin
								temp[15:8] <= mem_data_out;
								mem_raddr <= mem_raddr + 1;
								state <= EXEC7;
							end
							if(storb1) begin
								mem_write <= 1;
								state <= EXEC7;
							end
						end
			EXEC7	:	begin
							state <= FETCH1;
							if(loadb0) state <= EXEC8;
							if(storb0) begin
								mem_waddr <= mem_waddr + 1;
								mem_data_in <= r[R2][7:0];
								state <= EXEC8;
							end
						end
			EXEC8	:	begin
							state <= FETCH1;
							if(loadb0) begin
								r[R2][31:8] <= temp[31:8];
								r[R2][7:0] <= mem_data_out;
							end
							if(storb0) mem_write <= 1;
						end
			HALT	:	begin
							halted <= 1;
							state <= HALT;
						end
		endcase
	end

endmodule
