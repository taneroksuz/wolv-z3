import configure::*;
import wires::*;

module itim_tag
(
  input logic clk,
  input logic [0 : 0] wen,
  input logic [itim_depth-1 : 0] waddr,
  input logic [itim_depth-1 : 0] raddr,
  input logic [29-(itim_depth+itim_width) : 0] wdata,
  output logic [29-(itim_depth+itim_width) : 0] rdata
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [29-(itim_depth+itim_width):0] tag_array[0:2**itim_depth-1];
  logic [29-(itim_depth+itim_width):0] tag_rdata;

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

module itim_data
(
  input logic clk,
  input logic [0 : 0] wen,
  input logic [itim_depth-1 : 0] waddr,
  input logic [itim_depth-1 : 0] raddr,
  input logic [2**itim_width*32-1 : 0] wdata,
  output logic [2**itim_width*32-1 : 0] rdata
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [2**itim_width*32-1 : 0] data_array[0:2**itim_depth-1];
  logic [2**itim_width*32-1 : 0] data_rdata;

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

module itim_valid
(
  input logic clk,
  input logic [0 : 0] wen,
  input logic [itim_depth-1 : 0] waddr,
  input logic [itim_depth-1 : 0] raddr,
  input logic [0 : 0] wdata,
  output logic [0 : 0] rdata
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0 : 0] valid_array[0:2**itim_depth-1];
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

module itim_lock
(
  input logic clk,
  input logic [0 : 0] wen,
  input logic [itim_depth-1 : 0] waddr,
  input logic [itim_depth-1 : 0] raddr,
  input logic [0 : 0] wdata,
  output logic [0 : 0] rdata
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0 : 0] lock_array[0:2**itim_depth-1];
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
  parameter [1:0] fence = 3;

  typedef struct packed{
    logic [29-(itim_depth+itim_width):0] tag;
    logic [itim_width-1:0] wid;
    logic [itim_depth-1:0] did;
    logic [31:0] addr;
    logic [0:0] fence;
    logic [0:0] en;
  } front_type;

  parameter front_type init_front = '{
    tag : 0,
    wid : 0,
    did : 0,
    addr : 0,
    fence : 0,
    en : 0
  };

  typedef struct packed{
    logic [29-(itim_depth+itim_width):0] tag;
    logic [2**itim_width*32-1:0] data;
    logic [itim_width-1:0] wid;
    logic [itim_depth-1:0] did;
    logic [31:0] addr;
    logic [0:0] fence;
    logic [0:0] en;
    logic [0:0] hit;
    logic [0:0] miss;
    logic [0:0] load;
    logic [1:0] state;
  } back_type;

  parameter back_type init_back = '{
    tag : 0,
    data : 0,
    wid : 0,
    did : 0,
    addr : 0,
    fence : 0,
    en : 0,
    hit : 0,
    miss : 0,
    load : 0,
    state : fence
  };

  front_type r_f,rin_f;
  front_type v_f;

  back_type r_b,rin_b;
  back_type v_b;

  always_comb begin

    v_f = r_f;

    v_f.fence = 0;
    v_f.en = 0;

    if (itim_in.mem_valid == 1) begin
      if (itim_in.mem_fence == 1) begin
        v_f.fence = itim_in.mem_fence;
      end else begin
        v_f.en = itim_in.mem_valid;
        v_f.addr = itim_in.mem_addr;
        v_f.tag = itim_in.mem_addr[31:(itim_depth+itim_width+2)];
        v_f.did = itim_in.mem_addr[(itim_depth+itim_width+1):(itim_width+2)];
        v_f.wid = itim_in.mem_addr[(itim_width+1):2];
      end
    end

    rin_f = v_f;

  end

  always_comb begin

    v_b = r_b;

    v_b.fence = 0;
    v_b.en = 0;
    v_b.hit = 0;
    v_b.miss = 0;
    v_b.load = 0;

    if (r_b.state == hit) begin
      v_b.fence = r_f.fence;
      v_b.en = r_f.en;
      v_b.addr = r_f.addr;
      v_b.tag = r_f.tag;
      v_b.did = r_f.did;
      v_b.wid = r_f.wid;
    end

    case(r_b.state)
      hit :
        begin

        end
      miss :
        begin

        end
      load :
        begin

        end
      fence :
        begin

        end
      default :
        begin

        end
    endcase

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
