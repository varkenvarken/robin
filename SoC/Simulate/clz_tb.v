module test;
  reg [31:0] a;
  wire [31:0] n;
  
  clz dut(a,n);   

  integer i;
  initial 
    begin
      for(i=0; i<32; i=i+1)
      begin
        a = 1 << i;
        #1; // need to wait a bit to satisfy timing requirements
        if(n != 31 - i) begin
           $display("%h -> %0d (should be %0d)", a, n, 31 - i);
            $fatal(1);
        end
      end
      $finish(0);
    end
endmodule
