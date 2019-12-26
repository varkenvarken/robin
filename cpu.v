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
	reg [31:0] r[16];

	// special registers
	reg [15:0] instruction;

	reg [3:0] state;
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

	wire haltinstruction = &instruction; // all ones
	wire [addr_width-1:0] ip = r[15][addr_width-1:0]; // the addressable bits of the program counter

	always @(posedge clk) begin
		mem_write <= 0;
		if(reset) begin
			r[0] <= 0;
			r[1] <= 1;
			r[2] <= 0;
			r[15] <= start_address;
			halted <= 0;
			state <= START;
			instruction <= 0;
		end else
		if(halt | haltinstruction) begin
			state <= HALT;
			instruction <= 0;
		end else
			case(state)
				START	:	begin
								mem_raddr <= 0;
								state <= START1;
							end
				START1	:	begin
								r[2][15:8] <= mem_data_out; // no check for mem_ready yet
								mem_raddr <= 1;
								state <= START2;
							end
				START2	:	begin
								r[2][7:0] <= mem_data_out;
								state <= FETCH;
							end
				FETCH	:	begin
								mem_raddr <= ip;
								state <= FETCH1;
							end
				FETCH1	:	begin
								instruction[15:8] <= mem_data_out;
								r[15] <= r[15] + 1;
								state <= FETCH2;
							end
				FETCH2	:	begin
								mem_raddr <= ip;
								state <= FETCH3;
							end
				FETCH3	:	begin
								instruction[7:0] <= mem_data_out;
								r[15] <= r[15] + 1;
								state <= FETCH; // endless loop that basically just scans for 0xFFFF (halt)
							end
				HALT	:	begin
								mem_waddr <= 2;
								mem_data_in <= r[15][31:24];
								mem_write <= 1;
								state <= HALT1;
							end
				HALT1	:	begin
								state <= HALT2;
							end
				HALT2	:	begin
								mem_waddr <= 3;
								mem_data_in <= r[15][23:16];
								mem_write <= 1;
								state <= HALT3;
							end
				HALT3	:	begin
								state <= HALT4;
							end
				HALT4	:	begin
								mem_waddr <= 4;
								mem_data_in <= r[15][15:8];
								mem_write <= 1;
								state <= HALT5;
							end
				HALT5	:	begin
								state <= HALT6;
							end
				HALT6	:	begin
								mem_waddr <= 5;
								mem_data_in <= r[15][7:0];
								mem_write <= 1;
								state <= HALT7;
							end
				HALT7	:	begin
								halted <= 1;
								state <= HALTED;
							end
				HALTED	:	state <= HALTED;
				default	:	state <= HALT;
			endcase
	end

endmodule
