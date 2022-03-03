import configure::*;
import wires::*;

module itim
(
  input logic rst,
  input logic clk,
  input mem_in_type itim_in,
  output mem_out_type itim_out,
  input mem_out_type imem_out,
  output mem_in_type imem_in
);
	timeunit 1ns;
	timeprecision 1ps;

  parameter [1:0] hit = 0;
  parameter [1:0] miss = 1;
  parameter [1:0] load = 2;
  parameter [1:0] inv = 3;

  logic [31-(itim_width+itim_depth):0] itim_tag[0:2**itim_depth-1];
  logic [2**itim_depth*32-1 : 0] itim_data[0:2**itim_depth-1];
  logic [0 : 0] itim_valid[0:2**itim_depth-1];
  logic [0 : 0] itim_lock[0:2**itim_depth-1];

  typedef struct packed{
    logic [31-(itim_width+itim_depth):0] tag;
    logic [itim_width-1:0] wid;
    logic [itim_depth-1:0] did;
    logic [31:0] addr;
    logic [0:0] inv;
    logic [0:0] en;
  } front_type;

  parameter front_type init_front = '{
    tag : 0,
    wid : 0,
    did : 0,
    addr : 0,
    inv : 0,
    en : 0
  };

  typedef struct packed{
    logic [1:0] state;
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

  assign imem_in = itim_in;
  assign itim_out = imem_out;

endmodule
