import configure::*;

module itim
(
  input logic rst,
  input logic clk,
  input logic [0   : 0] itim_valid,
  input logic [0   : 0] itim_instr,
  input logic [31  : 0] itim_addr,
  input logic [31  : 0] itim_wdata,
  input logic [3   : 0] itim_wstrb,
  output logic [31 : 0] itim_rdata,
  output logic [0  : 0] itim_ready
);
	timeunit 1ns;
	timeprecision 1ps;

  logic [2**itim_depth*32-1 : 0] itim_ram[0:2**itim_depth-1];

  logic [0 : 0] itim_valid[0:2**itim_depth-1];

  logic [0 : 0] itim_lock[0:2**itim_depth-1];

  always_ff @(posedge clk) begin

  end

endmodule
