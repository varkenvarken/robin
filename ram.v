/* from reference inference example in 
Memory Usage Guide for iCE40 Devices Technical Note TN1250
*/

module ram (din, write_en, waddr, wclk, raddr, rclk, dout); //512x8 by default
	parameter addr_width = 9;
	parameter data_width = 8;
	input [addr_width-1:0] waddr, raddr;
	input [data_width-1:0] din;
	input write_en, wclk, rclk;
	output reg [data_width-1:0] dout;
	reg [data_width-1:0] mem [(1<<addr_width)-1:0]
	;

	always @(posedge wclk) // Write memory.
	begin
		if (write_en) mem[waddr] <= din; // Using write address bus.
	end
	always @(posedge rclk) // Read memory.
	begin
		dout <= mem[raddr]; // Using read address bus.
	end
endmodule
