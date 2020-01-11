/* robin, a SoC design for the IceBreaker board.
 *
 * robin.v : top level module with monitor program
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

`include "../puck/cores/osdvu/uart.v"  // outside the hierarchy so we have to include

`default_nettype	none

module top(
	input CLK,
	input RX,
	output TX,
	input BTN_N,
	input BTN1,
	input BTN2,
	input BTN3,
	output reg LED1,
	output reg LED2,
	output reg LED3,
	output reg LED4,
	output reg LED5,
	output reg LEDR_N,
	output reg LEDG_N);

	// button wires
	wire user_button, button1, button2,button3;
	debounce #(.INITIAL_STATE(1'b1)) debounce_ubutton(CLK, BTN_N, user_button);

	reg reset_button = 0;
	reg user_button_pressed = 0;
	always @(posedge CLK) begin
		reset_button <= 0;
		if(~ user_button & ~user_button_pressed) begin // pressed (negative logic)
			user_button_pressed <= 1;
			reset_button <= 1;	// a one clock strobe on pressing
		end else begin
			user_button_pressed <= 0;
		end
	end

	// uart wires
	reg [7:0] u_tx_byte;
	reg [7:0] u_rx_byte;
	reg u_transmit;
	wire u_received,u_is_transmitting;
	wire u_error;
	wire u_reset = ~reset; // uart reset is active high

	// global reset active low, cleared after startup, set on serial break or user button press
	// we keep this in reset state for 36 cycles to allow blockrams to produce valid data as per
	// https://github.com/cliffordwolf/icestorm/issues/76#issuecomment-289270411
	reg reset = 0;
	reg [5:0] reset_count = 0;
	always @(posedge CLK) begin
		if (reset_count == 36) // <-- set this to 36 to work around the issue
			reset <= 1;
		reset_count <= reset_count + 1;
	end

	localparam FIFO_ADDR_WIDTH = 8;		// we could go to 9 gving us buffers of 2⁹ == 512 bytes
	localparam MEM_ADDR_WIDTH = 18;		// this gives us of 2^18 == 256K bytes
	localparam LOWMEM_ADDR_WIDTH = 13;	// this gives us of 2¹³ == 8K bytes for the lowest ram block
	localparam LOWMEM_ADDR_WIDTH2 = 12;	// this gives us of 2^12 == 4K bytes for the next ram block (which might become a ROM later
	localparam LOWMEM_ADDR_WIDTH3 = 17;	// this gives us of 2^17 == 128K bytes for the spram block

	localparam DUMPWAIT = 16'hfff;		// additional wait time between sending chars (approx. .3 milliseconds) because u_is_transmitting not reliable)

	// the UART config. baudrate hardcoded.
	uart #(
		.baud_rate(115200),
		.sys_clk_freq(12000000)
	) uart0 (
		.clk(CLK),							// The master clock for this module
		.rst(u_reset),						// Synchronous reset
		.rx(RX),							// Incoming serial line
		.tx(TX),							// Outgoing serial line
		.transmit(u_transmit),				// Assert to begin transmission
		.tx_byte(u_tx_byte),				// Byte to transmit
		.received(u_received),				// Indicates that a byte has been received
		.rx_byte(u_rx_byte),				// Byte received
		.is_receiving(),					// Low when receive line is idle.
		.is_transmitting(u_is_transmitting),// Low when transmit line is idle.
		.recv_error(u_error)      			// Indicates error in receiving packet.
		// output reg [3:0] rx_samples,
		// output reg [3:0] rx_sample_countdown
	);

	// link uart error to red led. Will flash on break.
	always @(posedge CLK)
	begin
		LEDR_N <= ~u_error;
	end

	// receiving fifo
	reg fifo_in_read, fifo_in_write;
	reg [7:0] fifo_in_data_in;
	wire [7:0] fifo_in_data_out;
	wire fifo_in_full;
	wire fifo_in_empty;

	fifo #(.FIFO_ADDR_WIDTH(FIFO_ADDR_WIDTH)) 
	fifo_in(
		.clk(CLK),
		.reset_n(reset),
		.fifo_write(fifo_in_write),
		.fifo_data_in(fifo_in_data_in),
		.fifo_read(fifo_in_read),
		.fifo_data_out(fifo_in_data_out),
		.full(fifo_in_full),
		.empty(fifo_in_empty)
	);

	// cpu and wiring
	wire [7:0] cpu_data_in;
	wire [MEM_ADDR_WIDTH-1:0] cpu_waddr, cpu_raddr;
	wire cpu_write;
	wire [7:0] cpu_data_out;
	reg cpu_reset;
	reg cpu_halt;
	wire cpu_halted;

	cpu #(.addr_width(MEM_ADDR_WIDTH)) cpu0(
		.clk(CLK), 
		.mem_data_out(cpu_data_out),
		.mem_data_in(cpu_data_in),
		.mem_raddr(cpu_raddr),
		.mem_waddr(cpu_waddr),
		.mem_write(cpu_write),
		.mem_ready(1),
		.start_address(addr),
		.reset(cpu_reset),
		.halt(cpu_halt),
		.halted(cpu_halted)
	);

	reg running = 0;
	// link running indicatator to green led
	always @(posedge CLK)
	begin
		LEDG_N <= ~running;
	end

	// blockram
	// monitor managed registers (all mem_ prefixes probably should be renamed to to mon_ )
	reg [7:0] mem_data_in;
	reg [MEM_ADDR_WIDTH-1:0] mem_waddr, mem_raddr;
	reg mem_write;
	wire [7:0] mem_data_out;

	reg [7:0] inbyte;
	reg [7:0] bytes_available;
	wire override_byte = cpu_raddr == 256;
	wire override_nbytes = cpu_raddr == 257;
	wire clear_nbytes = (cpu_waddr == 257) & cpu_write;
	wire override_leds = cpu_waddr == 511;

	// blinkenlights module
	always @(posedge CLK) begin
		if(override_leds) begin
			LED2 <= cpu_data_in[0];
			LED3 <= cpu_data_in[1];
			LED4 <= cpu_data_in[2];
			LED5 <= cpu_data_in[3];
		end
	end

	// actual wiring to ram
	wire [7:0] ram_data_in;
	wire [MEM_ADDR_WIDTH-1:0] ram_waddr, ram_raddr;
	wire ram_write;
	wire [7:0] ram_data_out;

	assign ram_data_in = running ? cpu_data_in : mem_data_in;
	assign ram_waddr   = running ? cpu_waddr   : mem_waddr;
	assign ram_raddr   = running ? cpu_raddr   : mem_raddr;
	assign ram_write   = running ? cpu_write   : mem_write;
	assign mem_data_out= ram_data_out;
	assign cpu_data_out= override_byte ? inbyte : (override_nbytes ? bytes_available : ram_data_out);

	// first block [0,8k] (bram)
	wire ram_write0 = (ram_waddr[MEM_ADDR_WIDTH-1:13] == 5'b00000) & ram_write;
	wire ram_read0 = ram_raddr[MEM_ADDR_WIDTH-1:13] == 5'b00000;
	wire [LOWMEM_ADDR_WIDTH-1:0] ram_waddr0 = ram_waddr[LOWMEM_ADDR_WIDTH-1:0];
	wire [LOWMEM_ADDR_WIDTH-1:0] ram_raddr0 = ram_raddr[LOWMEM_ADDR_WIDTH-1:0] ;
	wire [7:0] ram_data_out0;
	// second block [8k,12k] (bram, used as preinitialized memory/rom)
	wire ram_write1 = (ram_waddr[MEM_ADDR_WIDTH-1:12] == 6'b000010) & ram_write;
	wire ram_read1 = ram_raddr[MEM_ADDR_WIDTH-1:12] == 6'b000010;
	wire [LOWMEM_ADDR_WIDTH2-1:0] ram_waddr1 = ram_waddr[LOWMEM_ADDR_WIDTH2-1:0];
	wire [LOWMEM_ADDR_WIDTH2-1:0] ram_raddr1 = ram_raddr[LOWMEM_ADDR_WIDTH2-1:0];
	wire [7:0] ram_data_out1;
	// second block [128k,256k]
	wire ram_write2 = (ram_waddr[MEM_ADDR_WIDTH-1] == 1'b1) & ram_write;
	wire ram_read2 = ram_raddr[MEM_ADDR_WIDTH-1] == 1'b1;
	wire [LOWMEM_ADDR_WIDTH3-1:0] ram_waddr2 = ram_waddr[LOWMEM_ADDR_WIDTH3-1:0];
	wire [LOWMEM_ADDR_WIDTH3-1:0] ram_raddr2 = ram_raddr[LOWMEM_ADDR_WIDTH3-1:0];
	wire [7:0] ram_data_out2;

	assign mem_data_out= ram_read0 ? ram_data_out0 : ram_read1 ? ram_data_out1 : ram_data_out2;

	ram #(.addr_width(LOWMEM_ADDR_WIDTH))
	mem0(
		.din		(ram_data_in), 
		.write_en	(ram_write0), 
		.waddr		(ram_waddr0), 
		.wclk(CLK), 
		.raddr		(ram_raddr0), 
		.rclk(CLK),
		.dout		(ram_data_out0)
	);

	ram #(.addr_width(LOWMEM_ADDR_WIDTH2), .rom_contents("rom.hex"))
	mem1(
		.din		(ram_data_in), 
		.write_en	(ram_write1), 
		.waddr		(ram_waddr1), 
		.wclk(CLK), 
		.raddr		(ram_raddr1), 
		.rclk(CLK),
		.dout		(ram_data_out1)
	);

	spram
	mem2(
		.clk(CLK),
		.wen(ram_write2),
		.addr(ram_write2 ? ram_waddr2 : ram_raddr2),
		.wdata(ram_data_in),
		.rdata(ram_data_out2)
	);

	// transmitting fifo
	reg fifo_out_read, fifo_out_write;
	reg [7:0] fifo_out_data_in;
	wire [7:0] fifo_out_data_out;
	wire fifo_out_full;
	wire fifo_out_empty;

	fifo #(.FIFO_ADDR_WIDTH(FIFO_ADDR_WIDTH)) 
	fifo_out(
		.clk(CLK),
		.reset_n(reset),
		.fifo_write(fifo_out_write),
		.fifo_data_in(fifo_out_data_in),
		.fifo_read(fifo_out_read),
		.fifo_data_out(fifo_out_data_out),
		.full(fifo_out_full),
		.empty(fifo_out_empty)
	);

	// transfer incoming bytes to the fifo 
	reg receiving = 0;
	always @(posedge CLK) begin
		fifo_in_write <= 0;
		if(~reset) begin
			receiving <= 0;
		end else if(u_received & ~receiving) begin
			fifo_in_data_in <= u_rx_byte;
			receiving <= 1;
		end else if(receiving) begin
			fifo_in_write <= 1;
			receiving <= 0;
		end 
	end

	// memory mapped serial transmit: write on address 0x100 will store byyte in output fifo
	wire output_available = (cpu_waddr == 256) & cpu_write;
	always @(posedge CLK) begin
		fifo_out_write <= 0;
		if(output_available)
		begin
			fifo_out_data_in <= cpu_data_in;
			fifo_out_write <= 1;
		end
	end

	// monitor, currently supports
	// load: transfer bytes to blockram
	//		01 <addr> <len> <byte ...>
	// dump: show bytes in blockram
	//		02 <addr> <len>
	// exec: run program (ignore <word>)
	//		03 <addr> <word>

	// monitor state
	reg [3:0] state = FLUSH;

	// control registers for the load and dump operations
	reg [7:0] bytes[6]; // cmd, adr1, adr2, adr3, len1, len2
	reg [2:0] rc;
	reg [15:0] len;
	reg [MEM_ADDR_WIDTH-1:0] addr;

	// monitor state machine
	localparam START   = 4'd0;
	localparam FLUSH   = 4'd1;
	localparam READ    = 4'd2;
	localparam READ1   = 4'd3;
	localparam PREP    = 4'd4;
	localparam DUMP0   = 4'd5;
	localparam DUMP1   = 4'd6;
	localparam DUMP2   = 4'd7;
	localparam LOAD0   = 4'd8;
	localparam LOAD1   = 4'd9;
	localparam LOAD2   = 4'd10;
	localparam EXEC0   = 4'd11;
	localparam EXEC1   = 4'd12;
	localparam EXEC2   = 4'd13;
	localparam RUN0    = 4'd14;
	localparam RUNNING = 4'd15;

	reg [7:0] tmp;
	reg [15:0] counter;
	always @(posedge CLK) begin
		fifo_in_read <= 0;
		fifo_out_read <= 0;
		u_transmit <= 0;
		mem_write <= 0;
		cpu_reset <= 0;
		if(~reset) begin
			state <= FLUSH;
			running <= 0;
			cpu_halt <= 1;
		end
		case(state)
			FLUSH:  begin
						if(counter)
							counter <= counter -1;
						else if(~fifo_in_empty)
							fifo_in_read <= 1;
						else if(~fifo_out_empty & ~u_is_transmitting)
							begin
								u_tx_byte <= fifo_out_data_out;
								fifo_out_read <= 1;
								u_transmit <= 1;
								counter <= DUMPWAIT;
							end
						else
							state <= START;
					end
			START:	begin
						rc <= 0;
						state <= READ;
					end
			READ:	begin
						if(~fifo_in_empty) begin
							bytes[rc] <= fifo_in_data_out;
							fifo_in_read <= 1;
							state <= READ1;
						end
					end
			READ1:	begin
						if(~u_is_transmitting) begin
							u_tx_byte <= bytes[rc];
							u_transmit <= 1;
							rc <= rc + 1;
							state <= rc == 5 ? PREP : READ;
						end
					end
			PREP:	begin
						addr = {bytes[1],bytes[2],bytes[3]};
						len  = {bytes[4],bytes[5]};
						case(bytes[0][1:0])
							1	: state <= LOAD0;
							2	: state <= DUMP0;
							3	: state <= EXEC2;
							default: state <= FLUSH;
						endcase
					end
			DUMP0:	begin
						if(len) begin
							mem_raddr <= addr;
							len <= len - 1;
							addr <= addr + 1;
							counter <= DUMPWAIT;
							state <= DUMP2;
						end else
							state <= START;
					end
			DUMP1:	begin
						if(~u_is_transmitting) begin
							u_tx_byte <= mem_data_out;
							u_transmit <= 1;
							state <= DUMP0;
						end
					end
			DUMP2:	if(counter)
						counter <= counter - 1;
					else
						state <= DUMP1;
			LOAD0:	begin
						if(len) begin
							mem_waddr <= addr;
							len <= len - 1;
							state <= LOAD1;
						end else
							state <= START;
					end
			LOAD1:	begin
						if(~fifo_in_empty) begin
							mem_data_in <= fifo_in_data_out;
							tmp <= fifo_in_data_out;
							fifo_in_read <= 1;
							mem_write <= 1;
							state <= LOAD2;
						end
					end
			LOAD2:	begin
						if(~u_is_transmitting) begin
							u_tx_byte <= tmp;
							u_transmit <= 1;
							state <= LOAD0;
							addr <= addr + 1;
						end
					end
//			EXEC0:	begin
//						mem_waddr <= 0;
//						mem_data_in <= len[15:8];
//						mem_write <= 1;
//						state <= EXEC1;
//					end
//			EXEC1:	begin
//						mem_waddr <= 1;
//						mem_data_in <= len[7:0];
//						mem_write <= 1;
//						state <= EXEC2;
//					end
			EXEC2:	begin
						cpu_halt <= 0;
						running <= 1;
						cpu_reset <= 1;
						state <= RUN0;
						LED1 <= 0;
					end
			RUN0:	begin
						state <= RUNNING;
						counter <= DUMPWAIT;
					end
			RUNNING:begin
						if(cpu_halted) begin
							running <= 0;
							state <= FLUSH;
							LED1 <= 1;
						end
						if(~fifo_in_empty & bytes_available == 0) begin
							inbyte <= fifo_in_data_out;
							fifo_in_read <= 1;
							bytes_available <= 1;
						end
						if(clear_nbytes) begin
							bytes_available <= 0;
						end
						if(counter)
							counter <= counter - 1;
						else begin
							if(~fifo_out_empty & ~u_is_transmitting) begin
								u_tx_byte <= fifo_out_data_out;
								fifo_out_read <= 1;
								u_transmit <= 1;
							end
							counter <= DUMPWAIT;
						end
					end
			default: state <= FLUSH;
		endcase
	end

endmodule
