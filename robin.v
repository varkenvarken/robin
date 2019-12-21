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
		end else if(fifo_in_read_en & fifo_in_bytes_received_nonzero ) begin
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

	wire button;
	debounce main_button(CLK,BTN_N,button);
	always @(posedge CLK) LED1 <= ~button;

	// this process reads a byte if the receive queue is not empty and a button is pressed
	// if so, it stores it in the transmit queue. 
	// this has the effect that we can receive the number of byytes that will fit into the
	// receive fifo and that we than echo those bytes one at a time for each keypress
	reg bytemarked = 0;
	reg wait_one = 0;
	reg echo_one = 0;
	reg button_on = 0;

	always @(posedge CLK) begin // should have reset signal to clear bytemarked and read signals
		fifo_in_read_en <= 0;
		fifo_out_read_en <= 0;
		if(wait_one) begin
			wait_one <= 0;
		end else if(bytemarked) begin   // we have a byte available to transmit
			fifo_out_read_en <= 1;
			bytemarked <= 0;
		end else if(fifo_in_bytes_received_nonzero & ~bytemarked & echo_one) begin  // read a byte only if instructed to do so
			fifo_in_read_en <= 1;
			bytemarked <= 1;
			wait_one <= 1;		// we introduce a wait cycle here to prevent the blockram from not settling on a new read address. With the single button press this is overkill because we cannot press that quickly 
			echo_one <= 0;
		end else if(~button & ~button_on) begin // if the button is pressed and wasn't pressed already we signal to echo 1 byte
			echo_one <= 1;
			button_on <= 1;		// we mark this button press so only if we release it again to we process the next char
		end else if(button) begin 
			button_on <= 0;
		end
	end

endmodule
