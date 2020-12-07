import configure::*;

module iram
(
  input logic rst,
  input logic clk,
  input logic [0   : 0] iram_valid,
  input logic [0   : 0] iram_instr,
  input logic [31  : 0] iram_addr,
  input logic [31  : 0] iram_wdata,
  input logic [3   : 0] iram_wstrb,
  output logic [31 : 0] iram_rdata,
  output logic [0  : 0] iram_ready
);
	timeunit 1ns;
	timeprecision 1ps;

  logic [31 : 0] iram_block[0:2**iram_depth-1];

  logic [31 : 0] rdata;
  logic [0  : 0] ready;

  initial begin
    $readmemh("iram.dat", iram_block);
  end

  always_ff @(posedge clk) begin

    if (iram_valid == 1) begin

      if (iram_wstrb[0] == 1)
        iram_block[iram_addr[(iram_depth+1):2]][7:0] <= iram_wdata[7:0];
      if (iram_wstrb[1] == 1)
        iram_block[iram_addr[(iram_depth+1):2]][15:8] <= iram_wdata[15:8];
      if (iram_wstrb[2] == 1)
        iram_block[iram_addr[(iram_depth+1):2]][23:16] <= iram_wdata[23:16];
      if (iram_wstrb[3] == 1)
        iram_block[iram_addr[(iram_depth+1):2]][31:24] <= iram_wdata[31:24];

      rdata <= iram_block[iram_addr[(iram_depth+1):2]];
      ready <= 1;

    end else begin

      ready <= 0;

    end

  end

  assign iram_rdata = rdata;
  assign iram_ready = ready;


endmodule
