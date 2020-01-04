// byte addressable spram
// uses all 128MB

module spram (
	input clk,
	input wen,
	input [16:0] addr,
	input [7:0] wdata,
	output [7:0] rdata
);

wire cs_0 = addr[16:15] == 0;
wire cs_1 = addr[16:15] == 1;
wire cs_2 = addr[16:15] == 2;
wire cs_3 = addr[16:15] == 3;

wire nibble_mask_hi = addr[14];
wire nibble_mask_lo = !addr[14];

wire [15:0] wdata16 = {wdata, wdata};

wire [15:0] rdata_0,rdata_1,rdata_2,rdata_3;
wire [7:0] rdata_0b = nibble_mask_hi ? rdata_0[15:8] : rdata_0[7:0];
wire [7:0] rdata_1b = nibble_mask_hi ? rdata_1[15:8] : rdata_1[7:0];
wire [7:0] rdata_2b = nibble_mask_hi ? rdata_2[15:8] : rdata_2[7:0];
wire [7:0] rdata_3b = nibble_mask_hi ? rdata_3[15:8] : rdata_3[7:0];

assign rdata = cs_0 ? rdata_0b : cs_1 ? rdata_1b : cs_2 ? rdata_2b : rdata_3b;

SB_SPRAM256KA ram0
  (
    .ADDRESS(addr[13:0]),
    .DATAIN(wdata16),
    .MASKWREN({nibble_mask_hi, nibble_mask_hi, nibble_mask_lo, nibble_mask_lo}),
    .WREN(wen),
    .CHIPSELECT(cs_0),
    .CLOCK(clk),
    .STANDBY(1'b0),
    .SLEEP(1'b0),
    .POWEROFF(1'b1),
    .DATAOUT(rdata_0)
  );

SB_SPRAM256KA ram1
  (
    .ADDRESS(addr[13:0]),
    .DATAIN(wdata16),
    .MASKWREN({nibble_mask_hi, nibble_mask_hi, nibble_mask_lo, nibble_mask_lo}),
    .WREN(wen),
    .CHIPSELECT(cs_1),
    .CLOCK(clk),
    .STANDBY(1'b0),
    .SLEEP(1'b0),
    .POWEROFF(1'b1),
    .DATAOUT(rdata_1)
  );

SB_SPRAM256KA ram2
  (
    .ADDRESS(addr[13:0]),
    .DATAIN(wdata16),
    .MASKWREN({nibble_mask_hi, nibble_mask_hi, nibble_mask_lo, nibble_mask_lo}),
    .WREN(wen),
    .CHIPSELECT(cs_2),
    .CLOCK(clk),
    .STANDBY(1'b0),
    .SLEEP(1'b0),
    .POWEROFF(1'b1),
    .DATAOUT(rdata_2)
  );

SB_SPRAM256KA ram3
  (
    .ADDRESS(addr[13:0]),
    .DATAIN(wdata16),
    .MASKWREN({nibble_mask_hi, nibble_mask_hi, nibble_mask_lo, nibble_mask_lo}),
    .WREN(wen),
    .CHIPSELECT(cs_3),
    .CLOCK(clk),
    .STANDBY(1'b0),
    .SLEEP(1'b0),
    .POWEROFF(1'b1),
    .DATAOUT(rdata_3)
  );

endmodule
