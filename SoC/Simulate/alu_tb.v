module test;
  reg [31:0] a,b,result;
  reg [3:0] op;
  wire [31:0] c;
  wire is_zero, is_negative;
  
  reg [31:0] x,y;
  reg [63:0] xw,yw,cw;

  integer n;

  alu dut(a,b,op,c,is_zero,is_negative);   

    localparam OP_ADD			= 0;
    localparam OP_SUB			= 1;
    localparam OP_AND			= 4;
    localparam OP_OR			= 5;
    localparam OP_XOR			= 6;
    localparam OP_NOT			= 7;
    localparam OP_CMP			= 8;
    localparam OP_TEST			= 9;
    localparam OP_CLZ			= 10;
    localparam OP_SHIFTLEFT		= 12;
    localparam OP_SHIFTRIGHT	= 13;
    localparam OP_MULLO			= 14;
    localparam OP_MULHI			= 15;
    
  localparam iterations = 100;
  
  integer i;
  initial
    begin
      for(i=0; i<iterations; i=i+1)  // add
      begin
        a = $urandom;
        b = $urandom;
        op = OP_ADD;
        result = a + b;
        #1; // need to wait a bit to satisfy timing requirements
        if(c != result) begin
           $display("%08h + %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(result incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if((result == 0) != is_zero) begin
           $display("%08h + %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(zero flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if(((result) & 32'h80000000) >> 31 != is_negative) begin
           $display("%08h + %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(negative flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
      end
      $display("OP_ADD ok");

      for(i=0; i<iterations; i=i+1)  // sub
      begin
        a = $urandom;
        b = $urandom;
        op = OP_SUB;
        result = a - b;
        #1; // need to wait a bit to satisfy timing requirements
        if(c != result) begin
           $display("%08h - %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(result incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if((result == 0) != is_zero) begin
           $display("%08h - %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(zero flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if(((result) & 32'h80000000) >> 31 != is_negative) begin
           $display("%08h - %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(negative flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
      end
      $display("OP_SUB ok");

      for(i=0; i<iterations; i=i+1)  // and
      begin
        a = $urandom;
        b = $urandom;
        op = OP_AND;
        result = a & b;
        #1; // need to wait a bit to satisfy timing requirements
        if(c != result) begin
           $display("%08h & %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(result incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if((result == 0) != is_zero) begin
           $display("%08h & %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(zero flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if(((result) & 32'h80000000) >> 31 != is_negative) begin
           $display("%08h & %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(negative flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
      end
      $display("OP_AND ok");

      for(i=0; i<iterations; i=i+1)  // or
      begin
        a = $urandom;
        b = $urandom;
        op = OP_OR;
        result = a | b;
        #1; // need to wait a bit to satisfy timing requirements
        if(c != result) begin
           $display("%08h | %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(result incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if((result == 0) != is_zero) begin
           $display("%08h | %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(zero flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if(((result) & 32'h80000000) >> 31 != is_negative) begin
           $display("%08h | %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(negative flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
      end
      $display("OP_OR  ok");

      for(i=0; i<iterations; i=i+1)  // xor
      begin
        a = $urandom;
        b = $urandom;
        op = OP_XOR;
        result = a ^ b;
        #1; // need to wait a bit to satisfy timing requirements
        if(c != result) begin
           $display("%08h ^ %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(result incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if((result == 0) != is_zero) begin
           $display("%08h ^ %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(zero flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if(((result) & 32'h80000000) >> 31 != is_negative) begin
           $display("%08h ^ %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(negative flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
      end
      $display("OP_XOR ok");

      for(i=0; i<iterations; i=i+1)  // not
      begin
        a = $urandom;
        b = $urandom;
        op = OP_NOT;
        result = ~a;
        #1; // need to wait a bit to satisfy timing requirements
        if(c != result) begin
           $display("~%08h (b:%08h) -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(result incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if((result == 0) != is_zero) begin
           $display("~%08h (b:%08h) -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(zero flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if(((result) & 32'h80000000) >> 31 != is_negative) begin
           $display("~%08h (b:%08h) -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(negative flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
      end
      $display("OP_NOT ok");

      for(i=0; i<iterations; i=i+1)  // cmp
      begin
        a = $urandom;
        b = $urandom;
        op = OP_CMP;
        result = $signed(a) - $signed(b);
        result = result & 32'h80000000 ? -1 : (result == 0 ? 0 : 1);
        #1; // need to wait a bit to satisfy timing requirements
        if(c != result) begin
           $display("%08h cmp %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(result incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if((result == 0) != is_zero) begin
           $display("%08h cmp %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(zero flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if(((result) & 32'h80000000) >> 31 != is_negative) begin
           $display("%08h cmp %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(negative flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
      end
      $display("OP_CMP ok");

      for(i=0; i<iterations; i=i+1)  // test
      begin
        a = $urandom;
        b = $urandom;
        op = OP_TEST;
        result = a;
        #1; // need to wait a bit to satisfy timing requirements
        if(c != result) begin
           $display("test %08h (b:%08h) -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(result incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if((result == 0) != is_zero) begin
           $display("test %08h (b:%08h) -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(zero flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if(((result) & 32'h80000000) >> 31 != is_negative) begin
           $display("test %08h (b:%08h) -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(negative flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
      end
      $display("OP_TEST ok");

      for(i=0; i<iterations; i=i+1)  // clz
      begin
        a = $urandom;
        b = $urandom;
        op = OP_CLZ;
        result = a;

        // next is an independent way to calculate the number of leading zeros, see Hackers Delight book
        x = a;
        n = 32;
        y = x >>16; if (y != 0) begin n = n -16; x = y; end
        y = x >> 8; if (y != 0) begin n = n - 8; x = y; end
        y = x >> 4; if (y != 0) begin n = n - 4; x = y; end
        y = x >> 2; if (y != 0) begin n = n - 2; x = y; end
        y = x >> 1; 
        if (y != 0)
            result = n - 2;
        else
            result = n - x;

        #1; // need to wait a bit to satisfy timing requirements
        if(c != result) begin
           $display("~%08h (b:%08h) -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(result incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if((result == 0) != is_zero) begin
           $display("~%08h (b:%08h) -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(zero flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if(((result) & 32'h80000000) >> 31 != is_negative) begin
           $display("~%08h (b:%08h) -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(negative flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
      end
      $display("OP_CLZ ok");

      for(i=0; i<iterations; i=i+1)  // <<
      begin
        a = $urandom;
        b = $urandom % 33;
        op = OP_SHIFTLEFT;
        result = a << b;
        #1; // need to wait a bit to satisfy timing requirements
        if(c != result) begin
           $display("%08h << %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(result incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if((result == 0) != is_zero) begin
           $display("%08h << %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(zero flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if(((result) & 32'h80000000) >> 31 != is_negative) begin
           $display("%08h << %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(negative flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
      end
      $display("OP_SHIFTLEFT  ok");

      for(i=0; i<iterations; i=i+1)  // <<
      begin
        a = $urandom;
        b = $urandom % 33;
        op = OP_SHIFTRIGHT;
        result = a >> b;
        #1; // need to wait a bit to satisfy timing requirements
        if(c != result) begin
           $display("%08h >> %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(result incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if((result == 0) != is_zero) begin
           $display("%08h >> %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(zero flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if(((result) & 32'h80000000) >> 31 != is_negative) begin
           $display("%08h >> %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(negative flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
      end
      $display("OP_SHIFTRIGHT  ok");

      for(i=0; i<iterations; i=i+1)  // mullo
      begin
        a = $urandom;
        b = $urandom;
        op = OP_MULLO;
        result = a * b;
        #1; // need to wait a bit to satisfy timing requirements
        if(c != result) begin
           $display("%08h * %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(result incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if((result == 0) != is_zero) begin
           $display("%08h * %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(zero flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if(((result) & 32'h80000000) >> 31 != is_negative) begin
           $display("%08h * %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(negative flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
      end
      $display("OP_MULLO ok");

      for(i=0; i<iterations; i=i+1)  // mulho
      begin
        a = $urandom;
        b = $urandom;
        op = OP_MULHI;
        xw = a;
        yw = b;
        cw = a * b;
        result = cw >> 32;
        #1; // need to wait a bit to satisfy timing requirements
        if(c != result) begin
           $display("%08h * %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(result incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if((result == 0) != is_zero) begin
           $display("%08h * %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(zero flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
        if(((result) & 32'h80000000) >> 31 != is_negative) begin
           $display("%08h * %08h -> %08h, z:%d n:%d (expected: %08h, z:%d n:%d)(negative flag incorrect)", a, b, c, is_zero, is_negative, result, (result)==0, ((result) & 32'h80000000)>>31);
           $fatal(1);
        end
      end
      $display("OP_MULHI ok");

      $finish(0);
    end

endmodule
