import configure::*;
import wires::*;

module dtim
(
  input logic rst,
  input logic clk,
  input mem_in_type dtim_in,
  output mem_out_type dtim_out,
  input mem_out_type dmem_out,
  output mem_in_type dmem_in
);
	timeunit 1ns;
	timeprecision 1ps;

  parameter [2:0] hit = 0;
  parameter [2:0] miss = 1;
  parameter [2:0] load = 2;
  parameter [2:0] store = 3;
  parameter [2:0] inv = 4;

  logic [31-(dtim_width+dtim_depth):0] dtim_tag[0:2**dtim_depth-1];
  logic [2**dtim_depth*32-1 : 0] dtim_block[0:2**dtim_depth-1];
  logic [0 : 0] dtim_valid[0:2**dtim_depth-1];
  logic [0 : 0] dtim_lock[0:2**dtim_depth-1];

  typedef struct packed{
    logic [31-(dtim_width+dtim_depth):0] tag;
    logic [dtim_width-1:0] wid;
    logic [dtim_depth-1:0] did;
    logic [31:0] addr;
    logic [31:0] data;
    logic [3:0] strb;
    logic [0:0] rden;
    logic [0:0] wren;
    logic [0:0] inv;
  } front_type;

  parameter front_type init_front = '{
    tag : 0,
    wid : 0,
    did : 0,
    addr : 0,
    data : 0,
    strb : 0,
    rden : 0,
    wren : 0,
    inv : 0
  };

  typedef struct packed{
    logic [2:0] state;
  } back_type;

  parameter back_type init_back = '{
    state : inv
  };

  front_type r_f,rin_f;
  front_type v_f;

  back_type r_b,rin_b;
  back_type v_b;

  always_comb begin

    v_f = r_f;

    rin_f = v_f;

  end

  always_comb begin

    v_b = r_b;

    rin_b = v_b;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r_f <= init_front;
      r_b <= init_back;
    end else begin
      r_f <= rin_f;
      r_b <= rin_b;
    end
  end

  assign dmem_in = dtim_in;
  assign dtim_out = dmem_out;

endmodule
