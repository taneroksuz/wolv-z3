import configure::*;
import constants::*;
import wires::*;

module writebuffer
(
  input logic rst,
  input logic clk,
  input mem_in_type writebuffer_in,
  output mem_out_type writebuffer_out,
  input mem_out_type dmem_out,
  output mem_in_type dmem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31 : 0] writebuffer_buffer[0:2**writebuffer_depth-1] = '{default:'0};

  typedef struct packed{
    logic [writebuffer_depth-1:0] waddr;
    logic [31:0] wdata;
    logic [0:0] wren;
    logic [0:0] stall;
  } reg_type;

  reg_type init_reg = '{
    waddr : 0,
    wdata : 0,
    wren : 0,
    stall : 0
  };

  reg_type r,rin;
  reg_type v;

  always_comb begin

    v = r;

    rin = v;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

  always_ff @(posedge clk) begin
    if (rin.wren == 1) begin
      writebuffer_buffer[rin.waddr] <= rin.wdata;
    end
  end

  assign dmem_in = writebuffer_in;
  assign writebuffer_out = dmem_out;

endmodule
