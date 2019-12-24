/* robin, a SoC design for the IceBreaker board.
 *
 * Copyright 2019 Michel Anders
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
	output reg LED1,
	output reg LED2,
	output reg LED3,
	output reg LED4,
	output reg LED5,
	output reg LEDR_N,
	output reg LEDG_N);

	// uart wires
	wire u_reset = 0;
	reg [7:0] u_tx_byte;
	reg [7:0] u_rx_byte;
	reg u_transmit;
	wire u_received,u_is_transmitting;
	wire u_break,u_error;
	wire u_reset;
	assign u_reset = ~reset; // uart reset is active high

	// global reset active low, cleared after startup
	reg reset = 0;
	always @(posedge CLK) reset <= 1;    // replace later with for example ~u_error to reset on break or on some button press

	localparam FIFO_ADDR_WIDTH = 4; // we could go to 9 gving us buffers of 2⁹ == 512 bytes
	localparam LOWMEM_ADDR_WIDTH = 13; // this gives us of 2¹³ == 8K bytes

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

	// blockram
	reg [7:0] mem_data_in;
	reg [LOWMEM_ADDR_WIDTH-1:0] mem_waddr, mem_raddr;
	reg mem_write;
	wire [7:0] mem_data_out;

	ram #(.addr_width(LOWMEM_ADDR_WIDTH))
	mem(
		.din		(mem_data_in), 
		.write_en	(mem_write), 
		.waddr		(mem_waddr), 
		.wclk(CLK), 
		.raddr		(mem_raddr), 
		.rclk(CLK),
		.dout		(mem_data_out)
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

	// monitor, currently supports
	// load: transfer bytes to blockram
	//		01 <addr> <len> <byte ...>
	// dump: show bytes in blockram
	//		02 <addr> <len>

	// monitor state, reflected in the green leds for debugging
	reg [3:0] state = FLUSH;
	always @(posedge CLK) begin
		LED2 <= state[0];
		LED3 <= state[1];
		LED4 <= state[2];
		LED5 <= state[3];
	end

	// control registers for the load and dump operations
	reg [7:0] bytes[6]; // cmd, adr1, adr2, adr3, len1, len2
	reg [2:0] rc;
	reg [15:0] len;
	reg [LOWMEM_ADDR_WIDTH-1:0] addr;

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

	reg [7:0] tmp;
	//reg waitcycle;
	reg [15:0] counter;
	always @(posedge CLK) begin
		fifo_in_read <= 0;
		u_transmit <= 0;
		mem_write <= 0;
		if(~reset) begin
			state <= FLUSH;
		end
		case(state)
			FLUSH:  begin
						if(~fifo_in_empty)
							fifo_in_read <= 1;
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
						addr = {bytes[2],bytes[3]};
						len  = {bytes[4],bytes[5]};
						state <= bytes[0][0] ? LOAD0: DUMP0;
					end
			DUMP0:	begin
						if(len) begin
							mem_raddr <= addr;
							len <= len - 1;
							addr <= addr + 1;
							counter <= 16'hfff;
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
			default: state <= START;
		endcase
	end

endmodule
