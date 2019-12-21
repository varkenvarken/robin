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

	localparam ADDR_WIDTH = 4;

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

	reg [ADDR_WIDTH-1:0] buf_waddr, buf_raddr;
	reg [7:0] buf_din;
	reg buf_write_en;
	wire [7:0] buf_dout;

	ram #(.addr_width(ADDR_WIDTH))
	buffer(
		.din		(buf_din), 
		.write_en	(buf_write_en), 
		.waddr		(buf_waddr), 
		.wclk(CLK), 
		.raddr		(buf_raddr), 
		.rclk(CLK),
		.dout		(buf_dout)
	);

	reg [ADDR_WIDTH-1:0] next_waddr, next_raddr;

	reg [ADDR_WIDTH-1:0] bytes_received;
	wire bytes_received_nonzero;
	assign bytes_received_nonzero = bytes_received != 0;

	always @(posedge CLK) begin
		buf_waddr <= next_waddr;
		buf_raddr <= next_raddr;
	end

	always @(posedge CLK) begin
		// store incoming
		if(u_received) begin
			buf_din <= u_rx_byte;
			buf_write_en <= 1;
			next_waddr <= buf_waddr + 1;
			bytes_received <= bytes_received + 1;
		end
		// transmit stored bytes
		u_transmit <= 0;
		if(~u_is_transmitting & bytes_received_nonzero) begin
			u_tx_byte <= buf_dout;
			u_transmit <= 1;
			next_raddr <= buf_raddr + 1;
			bytes_received <= bytes_received - 1;
		end
	end

endmodule
