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

`define COUNTER

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
`ifdef COUNTER
	reg [31:0] counter;
`endif

	// alu (combinatorial)
	wire [31:0] alu_a = r[R1];
	wire [31:0] alu_b = r[R0];
	wire [3:0] alu_op = r[13][3:0];
	wire multicycle   = r[13][4];
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

	// divider (multicycle)
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
	localparam DECODE		= 4;
	localparam EXEC1		= 5;
	localparam EXEC2		= 6;
	localparam EXEC3		= 7;
	localparam EXEC4		= 8;
	localparam EXEC5		= 9;
	localparam HALT			= 15;

	// instruction pointer
	wire [addr_width-1:0] ip = r[15][addr_width-1:0];  // the addressable bits of the program counter
	wire [31:0] ip1 = {{(32-addr_width){1'b0}},ip+1};  // incremented program counter, just for the addressable bits
	wire [31:0] ip2 = {{(32-addr_width){1'b0}},ip+2};  // pc + 2, just for the addressable bits

	// decoded signals
	reg pop;
	reg div, div_go;
	reg loadb3, loadb2, loadb1, loadb0;
	reg branch;
	reg storb3, storb2, storb1, storb0;
	reg loadli;

	// instruction fields
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

	// addressing
	wire [31:0] sumr1r0 = r[R1] + r[R0];
	wire [addr_width-1:0] sumr1r0_addr = sumr1r0[addr_width-1:0];

	// opcodes
	localparam CMD_MOVE    =  0;  // r2 <- r1 + r0
	localparam CMD_POP     =  1;  // r2 <- [r14] ; r14 += 4
	localparam CMD_ALU     =  2;  // r2 <- r1 alu_op r0
	localparam CMD_MOVER   =  3;  // r2 <- r1 + n*4
	localparam CMD_LOADB   =  4;  // r2 <- [r1 + r0] (byte)
	localparam CMD_SETBRA  =  5;  // r1 <- cond == true ; pc += cond == true ? offset : 0
	localparam CMD_LOADL   =  6;  // r2 <- [r1 + r0] (long)
	localparam CMD_LOADIL  =  7;  // r2 <- [pc] ; pc += 4 (long)
	localparam CMD_STORB   =  8;  // r2 -> [r1 + r0] (byte)
	localparam CMD_PUSH    =  9;  // r14 -= 4 ; r2 -> [r14]
	localparam CMD_STORL   = 10;  // r2 -> [r1 + r0] (long)
`ifdef COUNTER
	localparam CMD_MARK    = 11;  // r2 <- counter
`endif
	localparam CMD_LOADI   = 12;  // r2 <- byte
	localparam CMD_JUMP    = 14;  // r2 <- pc + 2 ; pc <- r1 + r0
	localparam CMD_HALT    = 15;  // halt

`ifdef COUNTER
	always @(posedge clk) begin
		counter <= counter + 1;
	end
`endif

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
		case(state)
			FETCH1	:	begin
							mem_raddr <= ip;  // address of instruction hi byte
							state <= FETCH2;
						end
			FETCH2	:	begin
							r[0] <= 0;        // make sure fixed registers stay fixed
							r[1] <= 1;
							r[13][31] <= 1;   // force the always on bit
							state <= FETCH3;  // there need to be two clock cycles between loading the mem_raddr and reading mem_data_out
							r[15] <= ip1;     // but then we can update and read every new clock cycle
							mem_raddr <= ip1; // address of instruction lo byte
							end
			FETCH3	:	begin                 // for efficiency reasons part of the decoding starts here already
							pop <= 0;
							instruction[15:8] <= mem_data_out;		// instruction hi byte
							state <= FETCH4;
							if(mem_data_out[7:4] == CMD_POP) begin  // to keep the read pipeline filled we either
								mem_raddr <= r[14];                 // start reading from whatever the stack pointer is
								pop <= 1;                           // then this will point to b3 (hi byte, big endian)
							end else begin                          // or we keep reading past the instruction 
								mem_raddr <= mem_raddr + 1;         // in case this will turn out to be a long immediate
							end                                     // then this will point to b3 (hi byte, big endian)
						end
			FETCH4	:	begin
							instruction[7:0] <= mem_data_out;       // instruction lo byte
							mem_raddr <= mem_raddr + 1;             // this will point to b2
							r[15] <= ip1;							// in the decode state ip will point to next instruction
							div_go <= 0;							// make sure the divider is reset
							state <= DECODE;
							div <= 0;								// all decoding signals reset (except for pop)
							loadb3 <= 0;
							loadb2 <= 0;
							loadb1 <= 0;
							loadb0 <= 0;
							branch <= 0;
							storb3 <= 0;
							storb2 <= 0;
							storb1 <= 0;
							storb0 <= 0;
							loadli <= 0;
						end
			DECODE	:	begin
							state <= EXEC1;
							mem_raddr <= mem_raddr + 1;				// this will point to b1
							case(cmd)
								CMD_MOVE:	begin
												state <= FETCH1;
												r[R2] <= sumr1r0;
												if( ~ &R2 ) begin	// if R2 is not the PC we can take a 1 cycle shortcut
													mem_raddr <= ip;
													state <= FETCH2;
												end
											end
								CMD_ALU:	begin
												if(multicycle) begin 
													div_go <= 1;	// start the divider module if we have a divider operation
													div <= 1;
												end	else begin
													r[R2] <= alu_c;
													r[13][29] <= alu_is_zero;
													r[13][30] <= alu_is_negative;
													state <= FETCH1;
													if( ~ &R2 ) begin // if R2 is not the PC we can take a 1 cycle shortcut
														mem_raddr <= ip;
														state <= FETCH2;
													end
												end
											end
								CMD_POP:	begin // empty instruction, pop was already set during fetch
												pop <= 1;
											end
								CMD_MOVER:	begin
												r[R2] <= r1_offset;
												state <= FETCH1;
												if( ~ &R2 ) begin	// if R2 is not the PC we can take a 1 cycle shortcut
													mem_raddr <= ip;
													state <= FETCH2;
												end
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
												loadli <= 1;
												r[15] <= ip2;  // we increment the pc in two steps to save on LUTs needed for adder
											end
								CMD_STORB:	begin
												storb3 <= 1;
												mem_waddr <= sumr1r0_addr;
												mem_data_in <= r[R2][7:0];
												mem_write <= 1;
											end
								CMD_PUSH:	begin
												r[14] <= r[14] - 4;
												mem_waddr <= r[14] - 4;
												mem_data_in <= r[R2][31:24];
												mem_write <= 1;
												storb3 <= 1;
												storb2 <= 1;
												storb1 <= 1;
												storb0 <= 1;
											end
								CMD_STORL:	begin
												storb3 <= 1;
												storb2 <= 1;
												storb1 <= 1;
												storb0 <= 1;
												mem_waddr <= sumr1r0_addr;
												mem_data_in <= r[R2][31:24];
												mem_write <= 1;
											end
								CMD_LOADI:	begin
												r[R2][7:0] <= immediate;
												state <= FETCH1;
												if( ~ &R2 ) begin	// if R2 is not the PC we can take a 1 cycle shortcut
													mem_raddr <= ip;
													state <= FETCH2;
												end
											end
								CMD_SETBRA:	begin
												branch <= 1;
												r[15] <= ip2;
												r[R1] <= takebranch; // R1 because R2 decodes the condition
												if( ~takebranch ) state <= FETCH1;
											end
								CMD_JUMP:	begin
												r[R2] <= r[15];
												r[15] <= sumr1r0;
												state <= FETCH1;
											end
`ifdef COUNTER
								CMD_MARK:	begin
												r[R2] <= counter;
											end
`endif
								default: state <= FETCH1;
							endcase
							temp[31:24] <= mem_data_out;  // read b3 for POP or LOADLI
						end
			EXEC1	:	begin
							temp[23:16] <= mem_data_out; // read b2 for POP or LOADLI
							mem_raddr <= mem_raddr + 1;  // this will point to b0 or b2
							div_go <= 0; // flag down the divider module again so that it is not reset forever
							state <= EXEC2;

							if (div) begin // a divider operation (multiple cycles)
								if(div_is_available) begin // keep cycling until done
									r[R2] <= div_c;
									r[13][29] <= div_is_zero;
									r[13][30] <= div_is_negative;
									state <= FETCH1;
								end else begin
									state <= EXEC1; 
								end
							end

							if(storb3 & ~storb2) begin
								mem_write <= 1;
								state <= FETCH1;
							end
							if(storb2) begin
								mem_waddr <= mem_waddr + 1;
								mem_data_in <= r[R2][23:16];
								mem_write <= 1;
							end

							if(loadli) r[15] <= ip2; // we increment the pc in two steps to save on LUTs needed for adder
						end
			EXEC2	:	begin
							mem_raddr <= mem_raddr + 1;		// the address for b1
							state <= FETCH1;

							if(loadb3) begin
								temp[31:24] <= mem_data_out;
								state <= EXEC3;
							end

							if(branch & takebranch) r[15] <= branchtarget; // branchtarget refers to upper half of temp so should be ready

							if(loadli | pop) begin
								temp[15:8] <= mem_data_out; // b1
								state <= EXEC3;
							end

							if(storb1) begin
								mem_waddr <= mem_waddr + 1;
								mem_data_in <= r[R2][15:8];
								mem_write <= 1;
								state <= EXEC3;
							end

							if(pop) r[14] <= r[14] + 4; // no need to set state because has been done by loadli | pop
						end
			EXEC3	:	begin
							mem_raddr <= mem_raddr + 1;  // the address for b0
							state <= FETCH1;

							if(loadb2) begin
								temp[23:16] <= mem_data_out;
								state <= EXEC4;
							end

							if(loadb3 & ~loadb2) r[R2][7:0] <= temp[31:24]; // a single byte load, not a long
							if(loadb3 & ~loadb2 & ~ &R2 ) begin	// if R2 is not the PC we can take a 1 cycle shortcut
								mem_raddr <= ip;
								state <= FETCH2;
							end

							if(loadli | pop) begin
								mem_raddr <= ip;
								state <= FETCH2;
								r[R2][31:8] <= temp[31:8];
								r[R2][7:0] <= mem_data_out;
							end

							if(storb0) begin
								mem_waddr <= mem_waddr + 1;
								mem_data_in <= r[R2][7:0];
								mem_write <= 1;
								state <= EXEC4;
							end
						end
			EXEC4	:	begin
							state <= FETCH1;

							if(loadb1) begin
								temp[15:8] <= mem_data_out;
								state <= EXEC5;
							end

							if(storb0) begin
								mem_write <= 1;
							end
						end
			EXEC5	:	begin
							mem_raddr <= ip;
							state <= FETCH2;
							// no need to test for signals only LOADL (loadb0) can end up in state == EXEC5
							r[R2][31:8] <= temp[31:8];
							r[R2][7:0] <= mem_data_out;
						end
			HALT	:	begin
							halted <= 1;
							state <= HALT;
						end
		endcase
	end

endmodule
