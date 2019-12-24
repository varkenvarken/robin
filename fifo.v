module fifo(clk, reset_n, fifo_write, fifo_data_in, fifo_read, fifo_data_out, full, empty);
	parameter FIFO_ADDR_WIDTH = 9;
	parameter FIFO_DATA_WIDTH = 8;
	input clk;
	input reset_n;
	input fifo_write;
	input [FIFO_DATA_WIDTH-1:0] fifo_data_in;
	input fifo_read;
	output reg [FIFO_DATA_WIDTH-1:0] fifo_data_out;
	output reg full;
	output reg empty;

	// internal variables
	reg [FIFO_ADDR_WIDTH-1:0] fifo_waddr, fifo_raddr;
	reg [FIFO_ADDR_WIDTH-1:0] fifo_next_waddr, fifo_next_raddr;
	reg [FIFO_ADDR_WIDTH-1:0] fifo_bytes_received;
	wire fifo_bytes_received_nonzero;
	assign fifo_bytes_received_nonzero = fifo_bytes_received != 0;

	// read/write pointer management
	always @(posedge clk) begin
		if(~reset_n) begin
			fifo_waddr <= 0;
			fifo_raddr <= 0;
		end else begin
			fifo_waddr <= fifo_next_waddr;
			fifo_raddr <= fifo_next_raddr;
		end
	end

	// block ram backing store
	ram #(.addr_width(FIFO_ADDR_WIDTH), .data_width(FIFO_DATA_WIDTH))
	fifo(
		.din		(fifo_data_in), 
		.write_en	(fifo_write), 
		.waddr		(fifo_waddr), 
		.wclk(clk), 
		.raddr		(fifo_raddr), 
		.rclk(clk),
		.dout		(fifo_data_out)
	);

	// read/write management
	always @(posedge clk) begin
		if(~reset_n) begin
			full <= 0;
			empty <= 1;
			fifo_bytes_received <= 0;
			fifo_next_waddr <= 0;
			fifo_next_raddr <= 0;
		end else if(fifo_write) begin
			fifo_next_waddr <= fifo_waddr + FIFO_ADDR_WIDTH'd1;
			fifo_bytes_received <= fifo_bytes_received + FIFO_ADDR_WIDTH'd1;
			// overrun is persistent until cleared by a read
			full <= full | (fifo_bytes_received + FIFO_ADDR_WIDTH'd1 == FIFO_ADDR_WIDTH'd0);
			empty <= 0;
		end else if(fifo_read & fifo_bytes_received_nonzero ) begin
			fifo_next_raddr <= fifo_raddr + FIFO_ADDR_WIDTH'd1;
			fifo_bytes_received <= fifo_bytes_received - FIFO_ADDR_WIDTH'd1;
			full <= 0;
			empty <= (fifo_bytes_received - FIFO_ADDR_WIDTH'd1 == FIFO_ADDR_WIDTH'd0);
		end
	end

endmodule
