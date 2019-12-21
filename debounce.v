// adapted from https://www.nandland.com/goboard/debounce-switch-project.html

module debounce(clk, switch_in, switch_out);
	parameter DEBOUNCE_LIMIT = 240000;  // 20 ms at 12 MHz
	parameter DEBOUNCE_SIZE = 18;        // number of bits needed to store DEBOUNCE_LIMIT
	input clk;
	input switch_in;
	output switch_out;

	reg [DEBOUNCE_SIZE-1:0] count = 0;
	reg state = 1'b0;
 
	always @(posedge clk)
	begin
		if (switch_in !== state && count < DEBOUNCE_LIMIT)
		begin // same but not yet long enough
			count <= count + 1;
		end else if (count == DEBOUNCE_LIMIT)
		begin 
			state <= switch_in;
			count <= 0;
		end else
		begin
			count <= 0;
		end
	end

	assign switch_out = state;  // the debounced output

endmodule
