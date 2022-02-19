import configure::*;

module dram
(
  input logic clk,
  input logic [0   : 0] dram_wen,
  input logic [dram_depth-1 : 0] dram_waddr,
  input logic [dram_depth-1 : 0] dram_raddr,
  input logic [31  : 0] dram_wdata,
  input logic [3   : 0] dram_wstrb,
  output logic [31 : 0] dram_rdata
);
	timeunit 1ns;
	timeprecision 1ps;

  logic [3 : 0][7 : 0] dram_block[0:2**dram_depth-1];

  logic [31 : 0] rdata;

  initial begin
    $readmemh("dram.dat", dram_block);
  end

  always_ff @(posedge clk) begin

    if (dram_wen == 1) begin

      if (dram_wstrb[0] == 1)
        dram_block[dram_waddr][0] <= dram_wdata[7:0];
      if (dram_wstrb[1] == 1)
        dram_block[dram_waddr][1] <= dram_wdata[15:8];
      if (dram_wstrb[2] == 1)
        dram_block[dram_waddr][2] <= dram_wdata[23:16];
      if (dram_wstrb[3] == 1)
        dram_block[dram_waddr][3] <= dram_wdata[31:24];

    end

    rdata <= dram_block[dram_raddr];

  end

  assign dram_rdata = rdata;


endmodule
