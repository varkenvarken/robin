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

	// global reset active low, cleared after startup
	reg reset = 0;
	always @(posedge CLK) reset <= 1;

	// uart wires
	wire u_reset = 0;
	reg [7:0] u_tx_byte;
	reg [7:0] u_rx_byte;
	reg u_transmit;
	wire u_received,u_is_transmitting;
	wire u_break,u_error;
	wire u_reset;
	assign u_reset = ~reset; // uart reset is active high

	localparam FIFO_ADDR_WIDTH = 4;

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

	// receiving fifo
	reg [FIFO_ADDR_WIDTH-1:0] fifo_in_waddr, fifo_in_raddr;
	reg [7:0] fifo_in_din;
	reg fifo_in_write_en;
	wire [7:0] fifo_in_dout;
	reg fifo_in_read_en; // for reading from the non-uart side 

	ram #(.addr_width(FIFO_ADDR_WIDTH))
	fifo_in(
		.din		(fifo_in_din), 
		.write_en	(fifo_in_write_en), 
		.waddr		(fifo_in_waddr), 
		.wclk(CLK), 
		.raddr		(fifo_in_raddr), 
		.rclk(CLK),
		.dout		(fifo_in_dout)
	);

	reg [FIFO_ADDR_WIDTH-1:0] fifo_in_next_waddr, fifo_in_next_raddr;

	reg [FIFO_ADDR_WIDTH-1:0] fifo_in_bytes_received;
	wire fifo_in_bytes_received_nonzero;
	assign fifo_in_bytes_received_nonzero = fifo_in_bytes_received != 0;

	always @(posedge CLK) begin
		fifo_in_waddr <= fifo_in_next_waddr;
		fifo_in_raddr <= fifo_in_next_raddr;
	end

	// transmitting fifo
	reg [FIFO_ADDR_WIDTH-1:0] fifo_out_waddr, fifo_out_raddr;
	reg [7:0] fifo_out_din;
	reg fifo_out_write_en;
	wire [7:0] fifo_out_dout;
	reg fifo_out_read_en; // for WRITing from the non-uart side

	ram #(.addr_width(FIFO_ADDR_WIDTH))
	fifo_out(
		.din		(fifo_out_din), 
		.write_en	(fifo_out_write_en), 
		.waddr		(fifo_out_waddr), 
		.wclk(CLK), 
		.raddr		(fifo_out_raddr), 
		.rclk(CLK),
		.dout		(fifo_out_dout)
	);

	reg [FIFO_ADDR_WIDTH-1:0] fifo_out_next_waddr, fifo_out_next_raddr;

	reg [FIFO_ADDR_WIDTH-1:0] fifo_out_bytes_received;
	wire fifo_out_bytes_received_nonzero;
	assign fifo_out_bytes_received_nonzero = fifo_out_bytes_received != 0;

	always @(posedge CLK) begin
		fifo_out_waddr <= fifo_out_next_waddr;
		fifo_out_raddr <= fifo_out_next_raddr;
	end

	// do something with ingoing and outgoing data
	reg [7:0] byte;

	always @(posedge CLK) begin
		// manage incoming queue
		fifo_in_write_en <= 0;
		if(u_received) begin
			fifo_in_din <= u_rx_byte;
			fifo_in_write_en <= 1;
			fifo_in_next_waddr <= fifo_in_waddr + 1;
			fifo_in_bytes_received <= fifo_in_bytes_received + 1;
		end else if(fifo_in_read_en & fifo_in_bytes_received_nonzero) begin
			byte <= fifo_in_dout;
			fifo_in_next_raddr <= fifo_in_raddr + 1;
			fifo_in_bytes_received <= fifo_in_bytes_received - 1;
		end
	end

	always @(posedge CLK) begin
		// manage outgoing queue
		u_transmit <= 0;
		if(~u_is_transmitting & fifo_out_bytes_received_nonzero) begin
			u_tx_byte <= fifo_out_dout;
			u_transmit <= 1;
			fifo_out_next_raddr <= fifo_out_raddr + 1;
			fifo_out_bytes_received <= fifo_out_bytes_received - 1;
		end else if(fifo_out_read_en) begin  // we store w.o check it is full right now, to be changed later
			fifo_out_din <= byte;
			fifo_out_write_en <= 1;
			fifo_out_next_waddr <= fifo_out_waddr + 1;
			fifo_out_bytes_received <= fifo_out_bytes_received + 1;
		end
	end

	// this process reads a byte if the receive queue is not empty
	// if a read byte is available, it stores it in the transmit queue
	reg bytemarked = 0;
	always @(posedge CLK) begin // should have reset signal to clear bytemarked and read signals
		fifo_in_read_en <= 0;
		fifo_out_read_en <= 0;
		if(fifo_in_bytes_received_nonzero & ~bytemarked) begin
			fifo_in_read_en <= 1;
			bytemarked <= 1;
		end else if(bytemarked) begin
			fifo_out_read_en <= 1;
			bytemarked <= 0;
		end
	end

endmodule
