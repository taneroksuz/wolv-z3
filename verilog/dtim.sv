import configure::*;

module dtim
(
  input logic rst,
  input logic clk,
  input logic [0   : 0] dtim_valid,
  input logic [0   : 0] dtim_instr,
  input logic [31  : 0] dtim_addr,
  input logic [31  : 0] dtim_wdata,
  input logic [3   : 0] dtim_wstrb,
  output logic [31 : 0] dtim_rdata,
  output logic [0  : 0] dtim_ready
);
	timeunit 1ns;
	timeprecision 1ps;

  logic [2**dtim_depth*32-1 : 0] dtim_block[0:2**dtim_depth-1];

  logic [0 : 0] dtim_valid[0:2**dtim_depth-1];

  logic [0 : 0] dtim_lock[0:2**dtim_depth-1];

  always_ff @(posedge clk) begin

  end


endmodule
