module test;
    reg clk;
    reg reset;
	reg [31:0] a;
	reg [31:0] b;
	reg go;
	reg divs;
	reg remainder;
	wire [31:0] c;
	wire is_zero;
	wire is_negative;
	wire available;

    reg [31:0] result;

    divider dut(clk, reset,
        a, b, go, divs, remainder,
        c, is_zero, is_negative, available
    );

    localparam iterations = 10000;

    always begin
        #1 clk <= ~clk;
    end

    integer start;
    integer i;

    initial begin
      // unsigned division
      #1 clk <= 0; reset <= 1;
      for(i=0; i<iterations; i=i+1)
      begin
          #2 go <= 0; start = $time;
          #2 reset <= 0; a <= $urandom; b <= $urandom; divs <= 0; remainder <= 0; go <= 1;
          #2 go <= 0; result <= a / b;
          while(~ available) begin
          #1;
          end
          if((result != c) | (is_zero != (result == 0)) | (is_negative != (((result) & 32'h80000000) >> 31))) begin
            $display("%08h / %08h = %08h [expected: %08h] (z:%1d [%1d] n:%1d [%1d] clk:%4d)",
                a,b,c,result,is_zero,result == 0,is_negative,((result) & 32'h80000000) >> 31,($time-start)/2);
            $fatal(1);
          end
      end
    
      $finish(0);
    end

endmodule
