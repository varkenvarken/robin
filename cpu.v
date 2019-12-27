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

	// special registers
	reg [15:0] instruction;
	reg [3:0] rc; // counter to iterate over all registers

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

	// state machine
	reg [5:0] state;
	localparam START	= 0;
	localparam START1	= 1;
	localparam START2	= 2;
	localparam FETCH	= 3;
	localparam HALT		= 4;
	localparam HALT1	= 5;
	localparam HALT2	= 6;
	localparam HALT3	= 7;
	localparam HALT4	= 8;
	localparam HALT5	= 9;
	localparam HALT6	= 10;
	localparam HALT7	= 11;
	localparam HALTED	= 12;
	localparam FETCH1	= 13;
	localparam FETCH2	= 14;
	localparam FETCH3	= 15;
	localparam DECODE	= 16;
	localparam EXECUTE	= 17;
	localparam LOAD1	= 18;
	localparam WRITEWAIT= 19;
	localparam WAIT     = 20;
	localparam START1b	= 21;
	localparam START1w	= 22;
	localparam START2w	= 23;
	localparam FETCH1w	= 24;
	localparam FETCH3w	= 25;
	localparam LOAD1w	= 26;
	localparam LOADWw	= 27;
	localparam LOADW1	= 28;
	localparam LOADLw	= 29;
	localparam LOADL1	= 30;
	localparam LOADLw2	= 31;
	localparam LOADL2	= 32;
	localparam WRITEWAITB= 33;
	localparam WRITEWAITW= 34;
	localparam WRITEWAITW1= 35;
	localparam WRITEWAITL= 36;
	localparam WRITEWAITL1= 37;
	localparam WRITEWAITL2= 38;
	localparam WRITEWAITL3= 39;

	wire haltinstruction = &instruction; // all ones
	wire [addr_width-1:0] ip = r[15][addr_width-1:0]; // the addressable bits of the program counter

	wire [3:0] cmd = instruction[15:12]; // main opcode
	wire [3:0] R2  = instruction[11: 8]; // destination register
	wire [3:0] R1  = instruction[ 7: 4]; // source register 1
	wire [3:0] R0  = instruction[ 3: 0]; // source register 0
	wire writable_destination = R2 > 1;	 // r0 and r1 are fixed at 0 and 1 respectively
	wire [7:0] immediate = instruction[7:0];

	// branch logic
	wire [31:0] relative = {{24{immediate[7]}},immediate}; // 8 bit sign extended to 32
	wire [31:0] branchtarget = r[15] + relative;
	wire takebranch = ((r[13][31:29] & instruction[10:8]) == ({3{instruction[11]}} & instruction[10:8]));

	wire [31:0] sumr1r0 = r[R1] + r[R0];
	wire [addr_width-1:0] sumr1r0_addr = sumr1r0[addr_width-1:0];

	localparam CMD_MOVEP =  0;
	localparam CMD_ALU   =  2;
	localparam CMD_LOADB =  4;
	localparam CMD_LOADW =  5;
	localparam CMD_LOADL =  6;
	localparam CMD_STORB =  8;
	localparam CMD_STORW =  9;
	localparam CMD_STORL = 10;
	localparam CMD_LOADI = 12;
	localparam CMD_BRANCH= 13;
	localparam CMD_JUMP  = 14;

	always @(posedge clk) begin
		mem_write <= 0;
		if(reset) begin
			r[0] <= 0;
			r[1] <= 1;
			r[2] <= 0;
			r[13] <= 32'h8000_0000; // flags register, bit 31 is always on, bit 30 is negative, bit 29 is zero, bit 28 is carry, bits [7;0] is aluop
			r[15] <= start_address;
			halted <= 0;
			state <= START;
			instruction <= 0;
		end else
		if(halt | haltinstruction) begin
			state <= HALT;
			instruction <= 0; // this will clear haltinstruction
			rc <= 0;
			mem_waddr_next <= 2; // start address of register dump
		end else
			case(state)
				START	:	begin
								mem_raddr <= 0;
								state <= START1w;
							end
				START1w	:	state <= START1;
				START1	:	begin
								r[2][15:8] <= mem_data_out; // no check for mem_ready yet
								state <= START1b;
							end
				START1b	:	begin
								mem_raddr <= 1;
								state <= START2w;
							end
				START2w	:	state <= START2;
				START2	:	begin
								r[2][7:0] <= mem_data_out;
								state <= FETCH;
							end
				FETCH	:	begin
								r[13][31] <= 1; // force the always on bit
								mem_raddr <= ip;
								state <= FETCH1w;
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
							end
				DECODE	:	state <= EXECUTE;
				EXECUTE :	begin
								state <= WAIT;
								case(cmd)
									CMD_MOVEP:	begin
													if(writable_destination) r[R2] <= sumr1r0;
												end
									CMD_ALU:	begin
													if(writable_destination) r[R2] <= alu_c;
													r[13][28] <= alu_carry_out;
													r[13][29] <= alu_is_zero;
													r[13][30] <= alu_is_negative;
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
													if(writable_destination) r[R2][7:0] <= immediate;
												end
									CMD_BRANCH:	begin
													if(takebranch) r[15] <= branchtarget;
												end
									CMD_JUMP:	begin
													if(writable_destination) r[R2] <= r[15];
													r[15] <= sumr1r0;
												end
									default: state <= FETCH;
								endcase
							end
				LOADLw	:	state <= LOADL1;
				LOADL1	:	begin
								if(writable_destination) r[R2][31:24] <= mem_data_out;
								mem_raddr <= mem_raddr + 1;
								state <= LOADLw2;
							end
				LOADLw2	:	state <= LOADL2;
				LOADL2	:	begin
								if(writable_destination) r[R2][23:16] <= mem_data_out;
								mem_raddr <= mem_raddr + 1;
								state <= LOADWw;
							end
				LOADWw	:	state <= LOADW1;
				LOADW1	:	begin
								if(writable_destination) r[R2][15:8] <= mem_data_out;
								mem_raddr <= mem_raddr + 1;
								state <= LOAD1w;
							end
				LOAD1w	:	state <= LOAD1;
				LOAD1	:	begin
								if(writable_destination) r[R2][7:0] <= mem_data_out;
								state <= FETCH;
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
				WAIT	:	state <= FETCH;
				HALT	:	begin
								mem_waddr <= mem_waddr_next;
								mem_data_in <= r[rc][31:24];
								state <= HALT1;
							end
				HALT1	:	begin
								mem_write <= 1;
								mem_waddr_next <= mem_waddr + 1;
								state <= HALT2;
							end
				HALT2	:	begin
								mem_waddr <= mem_waddr_next;
								mem_data_in <= r[rc][23:16];
								state <= HALT3;
							end
				HALT3	:	begin
								mem_write <= 1;
								mem_waddr_next <= mem_waddr + 1;
								state <= HALT4;
							end
				HALT4	:	begin
								mem_waddr <= mem_waddr_next;
								mem_data_in <= r[rc][15:8];
								state <= HALT5;
							end
				HALT5	:	begin
								mem_write <= 1;
								mem_waddr_next <= mem_waddr + 1;
								state <= HALT6;
							end
				HALT6	:	begin
								mem_waddr <= mem_waddr_next;
								mem_data_in <= r[rc][7:0];
								state <= HALT7;
							end
				HALT7	:	begin
								mem_write <= 1;
								mem_waddr_next <= mem_waddr + 1;
								rc <= rc + 1;
								state <= (rc == 4'b1111) ? HALTED : HALT;
							end
				HALTED	:	begin
								halted <= 1;
								state <= HALTED;
							end
				default	:	state <= HALT;
			endcase
	end

endmodule
