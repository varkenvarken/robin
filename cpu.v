/* robin, a SoC design for the IceBreaker board.
 *
 * cpu.v : a risc cpu
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

 module cpu(clk, mem_data_out, mem_data_in, mem_raddr, mem_waddr, mem_write, mem_ready, start_address, reset, halt, halted);
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
	wire alu_carry_in = r[13][28];
	wire [7:0] alu_op = r[13][7:0];
	wire [31:0] alu_c;
	wire alu_carry_out;
	wire alu_is_zero;
	wire alu_is_negative;

	alu alu0(
		.a(alu_a),
		.b(alu_b),
		.carry_in(alu_carry_in),
		.op(alu_op),
		.c(alu_c),
		.carry_out(alu_carry_out),
		.is_zero(alu_is_zero),
		.is_negative(alu_is_negative)
	);

	// divider
	wire [31:0] div_a = r[R1];
	wire [31:0] div_b = r[R0];
	wire [31:0] div_c;
	reg  div_go;
	wire div_divs = alu_op[0];
	wire remainder = alu_op[1];
	wire div_is_zero;
	wire div_is_negative;
	wire div_is_available;

	divider div(
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

	// cycle counter
	reg [15:0] counter;
	always @(posedge clk) begin
		if(reset)
			counter <= 0;
		else
			counter <= counter + 1;
	end

	// state machine
	reg [4:0] state;
	localparam FETCH		= 0;
	localparam FETCH1w		= 1;
	localparam FETCH1		= 2;
	localparam FETCH2		= 3;
	localparam FETCH3w		= 4;
	localparam FETCH3		= 5;
	localparam DECODE		= 6;
	localparam EXECUTE		= 7;
	localparam LOAD1		= 8;
	localparam LOAD1w		= 9;
	localparam LOADWw		= 10;
	localparam LOADW1		= 11;
	localparam LOADLw		= 12;
	localparam LOADL1		= 13;
	localparam LOADLw2		= 14;
	localparam LOADL2		= 15;
	localparam WRITEWAIT	= 16; // unused
	localparam WRITEWAITB	= 17;
	localparam WRITEWAITW	= 18;
	localparam WRITEWAITW1	= 19;
	localparam WRITEWAITL	= 20;
	localparam WRITEWAITL1	= 21;
	localparam WRITEWAITL2	= 22;
	localparam WRITEWAITL3	= 23;
	localparam WAIT			= 24;
	localparam HALT			= 25;
	localparam HALTED		= 26;
	localparam WAIT2		= 27;
	localparam WAIT3		= 28;
	localparam WAIT4		= 31;

	wire haltinstruction = &instruction; // all ones
	wire [addr_width-1:0] ip = r[15][addr_width-1:0]; // the addressable bits of the program counter

	reg pop;
	reg push;

	wire [3:0] cmd = instruction[15:12]; // main opcode
	wire [3:0] R2  = instruction[11: 8]; // destination register
	wire [3:0] R1  = instruction[ 7: 4]; // source register 1
	wire [3:0] R0  = instruction[ 3: 0]; // source register 0
	wire [7:0] immediate = instruction[7:0];
	wire [31:0] r1_offset = r[R1] + {{26{R0[3]}},R0,2'b00};  // sign extended offset * 4

	// branch logic
	wire [31:0] relative = {{24{immediate[7]}},immediate}; // 8 bit sign extended to 32
	wire [31:0] branchtarget = r[15] + relative;
	wire takebranch = ((r[13][31:29] & instruction[10:8]) == ({3{instruction[11]}} & instruction[10:8]));
	wire longbranch = (immediate == 8'b0) & (cmd == CMD_BRANCH);

	wire [31:0] sumr1r0 = r[R1] + r[R0];
	wire [addr_width-1:0] sumr1r0_addr = sumr1r0[addr_width-1:0];

	localparam CMD_MOVEP   =  0;
	localparam CMD_ALU     =  2;
	localparam CMD_MOVER   =  3;
	localparam CMD_LOADB   =  4;
	localparam CMD_LOADW   =  5;
	localparam CMD_LOADL   =  6;
	localparam CMD_LOADIL  =  7;
	localparam CMD_STORB   =  8;
	localparam CMD_STORW   =  9;
	localparam CMD_STORL   = 10;
	localparam CMD_LOADI   = 12;
	localparam CMD_BRANCH  = 13;
	localparam CMD_JUMP    = 14;
	localparam CMD_SPECIAL = 15; // note that halt (= 0xffff) is dealt with in a different manner

	always @(posedge clk) begin
		mem_write <= 0;
		if(reset) begin
			r[15] <= start_address;
			halted <= 0;
			state <= FETCH;
			instruction <= 0;
		end else
		if(halt | haltinstruction) begin
			state <= HALT;
			instruction <= 0; // this will clear haltinstruction
		end else
			case(state)
				FETCH	:	begin
								r[0] <= 0;
								r[1] <= 1;
								r[13][31] <= 1; // force the always on bit
								mem_raddr <= ip;
								state <= FETCH1w;
								pop <= 0;
								push <= 0;
							end
				FETCH1w	:	state <= FETCH1;
				FETCH1	:	begin
								instruction[15:8] <= mem_data_out;
								r[15] <= r[15] + 1;
								state <= FETCH2;
							end
				FETCH2	:	begin
								mem_raddr <= ip;
								state <= FETCH3w;
							end
				FETCH3w	:	state <= FETCH3;
				FETCH3	:	begin
								instruction[7:0] <= mem_data_out;
								r[15] <= r[15] + 1;
								state <= DECODE;
								div_go <= 0;
							end
				DECODE	:	begin
								state <= EXECUTE;
								if(alu_op[5]) div_go <= 1; // start the divider module if we have a divider operation
							end
				EXECUTE :	begin
								state <= WAIT;
								div_go <= 0;
								case(cmd)
									CMD_MOVEP:	begin
													r[R2] <= sumr1r0;
												end
									CMD_ALU:	begin
													if(~alu_op[5]) begin // regular alu operation (single cycle)
														r[R2] <= alu_c;
														r[13][28] <= alu_carry_out;
														r[13][29] <= alu_is_zero;
														r[13][30] <= alu_is_negative;
													end else begin // divider operation (multiple cycles)
														if(div_is_available) begin
															r[R2] <= div_c;
															r[13][29] <= div_is_zero;
															r[13][30] <= div_is_negative;
														end else
															state <= EXECUTE; 
													end
												end
									CMD_MOVER:	begin
													r[R2] <= r1_offset;
												end
									CMD_LOADB:	begin
													mem_raddr <= sumr1r0_addr;
													state <= LOAD1w;
												end
									CMD_LOADW:	begin
													mem_raddr <= sumr1r0_addr;
													state <= LOADWw;
												end
									CMD_LOADL:	begin
													mem_raddr <= sumr1r0_addr;
													state <= LOADLw;
												end
									CMD_LOADIL: begin
													mem_raddr <= r[15];
													r[15] <= r[15] + 4;
													state <= LOADLw;
												end
									CMD_STORB:	begin
													mem_waddr <= sumr1r0_addr;
													mem_data_in <= r[R2][7:0];
													state <= WRITEWAITB;
												end
									CMD_STORW:	begin
													mem_waddr <= sumr1r0_addr;
													mem_data_in <= r[R2][15:8];
													state <= WRITEWAITW;
												end
									CMD_STORL:	begin
													mem_waddr <= sumr1r0_addr;
													mem_data_in <= r[R2][31:24];
													state <= WRITEWAITL;
												end
									CMD_LOADI:	begin
													r[R2][7:0] <= immediate;
												end
									CMD_BRANCH:	begin
													if(longbranch) begin
														r[15] <= r[15] + 4;
														if(takebranch) begin
															mem_raddr <= r[15];
															state <= LOADLw;
														end
													end else if(takebranch) begin
														r[15] <= branchtarget;
													end
												end
									CMD_JUMP:	begin
													r[R2] <= r[15];
													r[15] <= sumr1r0;
												end
									CMD_SPECIAL:begin
													state <= FETCH;
													case(immediate)
														8'd0:	r[R2] <= {16'b0, counter};
														8'd1:	begin
																	mem_raddr <= r[14];
																	state <= LOADLw;
																	pop <= 1;
																end
														8'd2:	begin
																	r[14] <= r[14] - 4;
																	state <= WAIT4;
																end
														default: state <= FETCH;
													endcase
												end
									default: state <= FETCH;
								endcase
							end
				LOADLw	:	state <= LOADL1;
				LOADL1	:	begin
								if(longbranch)
									temp[31:24] <= mem_data_out;
								else
									r[R2][31:24] <= mem_data_out;
								mem_raddr <= mem_raddr + 1;
								state <= LOADLw2;
								if(pop) r[14] <= r[14] + 4;
							end
				LOADLw2	:	state <= LOADL2;
				LOADL2	:	begin
								if(longbranch)
									temp[23:16] <= mem_data_out;
								else
									r[R2][23:16] <= mem_data_out;
								mem_raddr <= mem_raddr + 1;
								state <= LOADWw;
							end
				LOADWw	:	state <= LOADW1;
				LOADW1	:	begin
								if(longbranch)
									temp[15:8] <= mem_data_out;
								else
									r[R2][15:8] <= mem_data_out;
								mem_raddr <= mem_raddr + 1;
								state <= LOAD1w;
							end
				LOAD1w	:	state <= LOAD1;
				LOAD1	:	begin
								state <= FETCH;
								if(longbranch) begin
									temp[7:0] <= mem_data_out;
									state <= WAIT;
								end else
									r[R2][7:0] <= mem_data_out;
							end
				WAIT4:		begin
								mem_waddr <= r[14];
								mem_data_in <= r[R2][31:24];
								state <= WRITEWAITL;
							end
				WRITEWAITL:	begin
								mem_write <= 1;
								state <= WRITEWAITL1;
							end
				WRITEWAITL1:begin
								mem_waddr <= mem_waddr + 1;
								mem_data_in <= r[R2][23:16];
								state <= WRITEWAITL2;
							end
				WRITEWAITL2:begin
								mem_write <= 1;
								state <= WRITEWAITL3;
							end
				WRITEWAITL3:begin
								mem_waddr <= mem_waddr + 1;
								mem_data_in <= r[R2][15:8];
								state <= WRITEWAITW;
							end
				WRITEWAITW:	begin
								mem_write <= 1;
								state <= WRITEWAITW1;
							end
				WRITEWAITW1:begin
								mem_waddr <= mem_waddr + 1;
								mem_data_in <= r[R2][7:0];
								state <= WRITEWAITB;
							end
				WRITEWAITB:	begin
								mem_write <= 1;
								state <= WAIT;
							end
				WAIT	:	begin
								if(longbranch)
									state <= WAIT2;
								else
									state <= FETCH;
							end
				WAIT2	:	begin
								r[15] <= r[15] + temp;
								state <= WAIT3;
							end
				WAIT3	:	state <= FETCH;
				HALT	:	begin
								state <= HALTED;
							end
				HALTED	:	begin
								halted <= 1;
								state <= HALTED;
							end
				default	:	state <= HALT;
			endcase
	end

endmodule
