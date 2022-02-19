import configure::*;

module dram
(
  input logic rst,
  input logic clk,
  input logic [0   : 0] dram_valid,
  input logic [0   : 0] dram_instr,
  input logic [31  : 0] dram_addr,
  input logic [31  : 0] dram_wdata,
  input logic [3   : 0] dram_wstrb,
  output logic [31 : 0] dram_rdata,
  output logic [0  : 0] dram_ready
);
	timeunit 1ns;
	timeprecision 1ps;

  logic [31 : 0] dram_block[0:2**dram_depth-1];

  logic [31 : 0] rdata;
  logic [0  : 0] ready;

  initial begin
    $readmemh("dram.dat", dram_block);
  end

  always_ff @(posedge clk) begin

    if (dram_valid == 1) begin

      if (dram_wstrb[0] == 1)
        dram_block[dram_addr[(dram_depth+1):2]][7:0] <= dram_wdata[7:0];
      if (dram_wstrb[1] == 1)
        dram_block[dram_addr[(dram_depth+1):2]][15:8] <= dram_wdata[15:8];
      if (dram_wstrb[2] == 1)
        dram_block[dram_addr[(dram_depth+1):2]][23:16] <= dram_wdata[23:16];
      if (dram_wstrb[3] == 1)
        dram_block[dram_addr[(dram_depth+1):2]][31:24] <= dram_wdata[31:24];

      rdata <= dram_block[dram_addr[(dram_depth+1):2]];
      ready <= 1;

    end else begin

      ready <= 0;

    end

  end

  assign dram_rdata = rdata;
  assign dram_ready = ready;


endmodule
