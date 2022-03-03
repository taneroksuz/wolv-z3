import configure::*;
import wires::*;

module dtim_tag
(
  input logic clk,
  input logic [0 : 0] wen,
  input logic [dtim_depth-1 : 0] waddr,
  input logic [dtim_depth-1 : 0] raddr,
  input logic [29-(dtim_depth+dtim_width) : 0] wdata,
  output logic [29-(dtim_depth+dtim_width) : 0] rdata
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [29-(dtim_depth+dtim_width):0] tag_array[0:2**dtim_depth-1];
  logic [29-(dtim_depth+dtim_width):0] tag_rdata;

  initial begin
    tag_array = '{default:'0};
    tag_rdata = 0;
  end

  assign rdata = tag_rdata;

  always_ff @(posedge clk) begin
    if (wen == 1) begin
      tag_array[waddr] <= wdata;
    end
    tag_rdata <= tag_array(raddr);
  end

endmodule

module dtim_data
(
  input logic clk,
  input logic [0 : 0] wen,
  input logic [dtim_depth-1 : 0] waddr,
  input logic [dtim_depth-1 : 0] raddr,
  input logic [2**dtim_width*32-1 : 0] wdata,
  output logic [2**dtim_width*32-1 : 0] rdata
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [2**dtim_width*32-1 : 0] data_array[0:2**dtim_depth-1];
  logic [2**dtim_width*32-1 : 0] data_rdata;

  initial begin
    data_array = '{default:'0};
    data_rdata = 0;
  end

  assign rdata = tag_rdata;

  always_ff @(posedge clk) begin
    if (wen == 1) begin
      data_array[waddr] <= wdata;
    end
    data_rdata <= data_array(raddr);
  end

endmodule

module dtim_valid
(
  input logic clk,
  input logic [0 : 0] wen,
  input logic [dtim_depth-1 : 0] waddr,
  input logic [dtim_depth-1 : 0] raddr,
  input logic [0 : 0] wdata,
  output logic [0 : 0] rdata
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0 : 0] valid_array[0:2**dtim_depth-1];
  logic [0 : 0] valid_rdata;

  initial begin
    valid_array = '{default:'0};
    valid_rdata = 0;
  end

  assign rdata = valid_rdata;

  always_ff @(posedge clk) begin
    if (wen == 1) begin
      valid_array[waddr] <= wdata;
    end
    valid_rdata <= valid_array(raddr);
  end

endmodule

module dtim_lock
(
  input logic clk,
  input logic [0 : 0] wen,
  input logic [dtim_depth-1 : 0] waddr,
  input logic [dtim_depth-1 : 0] raddr,
  input logic [0 : 0] wdata,
  output logic [0 : 0] rdata
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0 : 0] lock_array[0:2**dtim_depth-1];
  logic [0 : 0] lock_rdata;

  initial begin
    lock_array = '{default:'0};
    lock_rdata = 0;
  end

  assign rdata = lock_rdata;

  always_ff @(posedge clk) begin
    if (wen == 1) begin
      lock_array[waddr] <= wdata;
    end
    lock_rdata <= lock_array(raddr);
  end

endmodule

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

  assign dmem_in = dtim_in;
  assign dtim_out = dmem_out;

endmodule
