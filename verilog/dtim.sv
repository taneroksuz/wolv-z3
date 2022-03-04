package dtim_wires;
  import configure::*;

  timeunit 1ns;
  timeprecision 1ps;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [dtim_depth-1 : 0] waddr;
    logic [dtim_depth-1 : 0] raddr;
    logic [29-(dtim_depth+dtim_width) : 0] wdata;
  } dtim_tag_in_type;

  typedef struct packed{
    logic [29-(dtim_depth+dtim_width) : 0] rdata;
  } dtim_tag_out_type;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [dtim_depth-1 : 0] waddr;
    logic [dtim_depth-1 : 0] raddr;
    logic [2**dtim_width*32-1 : 0] wdata;
  } dtim_data_in_type;

  typedef struct packed{
    logic [2**dtim_width*32-1 : 0] rdata;
  } dtim_data_out_type;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [dtim_depth-1 : 0] waddr;
    logic [dtim_depth-1 : 0] raddr;
    logic [0 : 0] wdata;
  } dtim_valid_in_type;

  typedef struct packed{
    logic [0 : 0] rdata;
  } dtim_valid_out_type;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [dtim_depth-1 : 0] waddr;
    logic [dtim_depth-1 : 0] raddr;
    logic [0 : 0] wdata;
  } dtim_lock_in_type;

  typedef struct packed{
    logic [0 : 0] rdata;
  } dtim_lock_out_type;

  typedef struct packed{
    dtim_tag_out_type tag_out;
    dtim_data_out_type data_out;
    dtim_valid_out_type valid_out;
    dtim_lock_out_type lock_out;
  } dtim_ctrl_in_type;

  typedef struct packed{
    dtim_tag_in_type tag_in;
    dtim_data_in_type data_in;
    dtim_valid_in_type valid_in;
    dtim_lock_in_type lock_in;
  } dtim_ctrl_out_type;

endpackage

import configure::*;
import dtim_wires::*;

module dtim_tag
(
  input logic clk,
  input dtim_tag_in_type dtim_tag_in,
  output dtim_tag_out_type dtim_tag_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [29-(dtim_depth+dtim_width):0] tag_array[0:2**dtim_depth-1];
  logic [29-(dtim_depth+dtim_width):0] tag_rdata;

  initial begin
    tag_array = '{default:'0};
    tag_rdata = 0;
  end

  assign dtim_tag_out.rdata = tag_rdata;

  always_ff @(posedge clk) begin
    if (dtim_tag_in.wen == 1) begin
      tag_array[dtim_tag_in.waddr] <= dtim_tag_in.wdata;
    end
    tag_rdata <= tag_array[dtim_tag_in.raddr];
  end

endmodule

module dtim_data
(
  input logic clk,
  input dtim_data_in_type dtim_data_in,
  output dtim_data_out_type dtim_data_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [2**dtim_width*32-1 : 0] data_array[0:2**dtim_depth-1];
  logic [2**dtim_width*32-1 : 0] data_rdata;

  initial begin
    data_array = '{default:'0};
    data_rdata = 0;
  end

  assign dtim_data_out.rdata = data_rdata;

  always_ff @(posedge clk) begin
    if (dtim_data_in.wen == 1) begin
      data_array[dtim_data_in.waddr] <= dtim_data_in.wdata;
    end
    data_rdata <= data_array[dtim_data_in.raddr];
  end

endmodule

module dtim_valid
(
  input logic clk,
  input dtim_valid_in_type dtim_valid_in,
  output dtim_valid_out_type dtim_valid_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0 : 0] valid_array[0:2**dtim_depth-1];
  logic [0 : 0] valid_rdata;

  initial begin
    valid_array = '{default:'0};
    valid_rdata = 0;
  end

  assign dtim_valid_out.rdata = valid_rdata;

  always_ff @(posedge clk) begin
    if (dtim_valid_in.wen == 1) begin
      valid_array[dtim_valid_in.waddr] <= dtim_valid_in.wdata;
    end
    valid_rdata <= valid_array[dtim_valid_in.raddr];
  end

endmodule

module dtim_lock
(
  input logic clk,
  input dtim_lock_in_type dtim_lock_in,
  output dtim_lock_out_type dtim_lock_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0 : 0] lock_array[0:2**dtim_depth-1];
  logic [0 : 0] lock_rdata;

  initial begin
    lock_array = '{default:'0};
    lock_rdata = 0;
  end

  assign dtim_lock_out.rdata = lock_rdata;

  always_ff @(posedge clk) begin
    if (dtim_lock_in.wen == 1) begin
      lock_array[dtim_lock_in.waddr] <= dtim_lock_in.wdata;
    end
    lock_rdata <= lock_array[dtim_lock_in.raddr];
  end

endmodule

module dtim_ctrl
(
  input logic rst,
  input logic clk,
  input dtim_ctrl_in_type dctrl_in,
  output dtim_ctrl_out_type dctrl_out,
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
  parameter [2:0] fence = 4;

  typedef struct packed{
    logic [29-(dtim_depth+dtim_width):0] tag;
    logic [dtim_width-1:0] wid;
    logic [dtim_depth-1:0] did;
    logic [31:0] addr;
    logic [31:0] data;
    logic [3:0] strb;
    logic [0:0] rden;
    logic [0:0] wren;
    logic [0:0] fence;
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
    fence : 0
  };

  typedef struct packed{
    logic [2:0] state;
  } back_type;

  parameter back_type init_back = '{
    state : fence
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

endmodule

module dtim
#(
  parameter dtim_enable = 1
)
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

  generate

    if (dtim_enable == 1) begin

      dtim_ctrl_in_type dctrl_in;
      dtim_ctrl_out_type dctrl_out;

      dtim_tag dtim_tag_comp
      (
        .clk (clk),
        .dtim_tag_in (dctrl_out.tag_in),
        .dtim_tag_out (dctrl_in.tag_out)
      );

      dtim_data dtim_data_comp
      (
        .clk (clk),
        .dtim_data_in (dctrl_out.data_in),
        .dtim_data_out (dctrl_in.data_out)
      );

      dtim_valid dtim_valid_comp
      (
        .clk (clk),
        .dtim_valid_in (dctrl_out.valid_in),
        .dtim_valid_out (dctrl_in.valid_out)
      );

      dtim_lock dtim_lock_comp
      (
        .clk (clk),
        .dtim_lock_in (dctrl_out.lock_in),
        .dtim_lock_out (dctrl_in.lock_out)
      );

      dtim_ctrl dtim_ctrl_comp
      (
        .rst (rst),
        .clk (clk),
        .dctrl_in (dctrl_in),
        .dctrl_out (dctrl_out),
        .dtim_in (dtim_in),
        .dtim_out (dtim_out),
        .dmem_out (dmem_out),
        .dmem_in (dmem_in)
      );

    end else begin

      assign dmem_in = dtim_in;
      assign dtim_out = dmem_out;

    end

  endgenerate

endmodule
