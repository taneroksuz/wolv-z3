import configure::*;

module iram
(
  input logic clk,
  input logic [0   : 0] iram_wen,
  input logic [iram_depth-1 : 0] iram_waddr,
  input logic [iram_depth-1 : 0] iram_raddr,
  input logic [31  : 0] iram_wdata,
  input logic [3   : 0] iram_wstrb,
  output logic [31 : 0] iram_rdata
);
	timeunit 1ns;
	timeprecision 1ps;

  logic [3 : 0][7 : 0] iram_block[0:2**iram_depth-1];

  logic [31 : 0] rdata;

  initial begin
    $readmemh("iram.dat", iram_block);
  end

  always_ff @(posedge clk) begin

    if (iram_wen == 1) begin

      if (iram_wstrb[0] == 1)
        iram_block[iram_waddr][0] <= iram_wdata[7:0];
      if (iram_wstrb[1] == 1)
        iram_block[iram_waddr][1] <= iram_wdata[15:8];
      if (iram_wstrb[2] == 1)
        iram_block[iram_waddr][2] <= iram_wdata[23:16];
      if (iram_wstrb[3] == 1)
        iram_block[iram_waddr][3] <= iram_wdata[31:24];

    end

    rdata <= iram_block[iram_raddr];

  end

  assign iram_rdata = rdata;


endmodule
