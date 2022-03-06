package itim_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [itim_depth-1 : 0] waddr;
    logic [itim_depth-1 : 0] raddr;
    logic [29-(itim_depth+itim_width) : 0] wdata;
  } itim_tag_in_type;

  typedef struct packed{
    logic [29-(itim_depth+itim_width) : 0] rdata;
  } itim_tag_out_type;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [itim_depth-1 : 0] waddr;
    logic [itim_depth-1 : 0] raddr;
    logic [2**itim_width*32-1 : 0] wdata;
  } itim_data_in_type;

  typedef struct packed{
    logic [2**itim_width*32-1 : 0] rdata;
  } itim_data_out_type;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [itim_depth-1 : 0] waddr;
    logic [itim_depth-1 : 0] raddr;
    logic [0 : 0] wdata;
  } itim_valid_in_type;

  typedef struct packed{
    logic [0 : 0] rdata;
  } itim_valid_out_type;

  typedef struct packed{
    logic [0 : 0] wen;
    logic [itim_depth-1 : 0] waddr;
    logic [itim_depth-1 : 0] raddr;
    logic [0 : 0] wdata;
  } itim_lock_in_type;

  typedef struct packed{
    logic [0 : 0] rdata;
  } itim_lock_out_type;

  typedef struct packed{
    itim_tag_out_type tag_out;
    itim_data_out_type data_out;
    itim_valid_out_type valid_out;
    itim_lock_out_type lock_out;
  } itim_ctrl_in_type;

  typedef struct packed{
    itim_tag_in_type tag_in;
    itim_data_in_type data_in;
    itim_valid_in_type valid_in;
    itim_lock_in_type lock_in;
  } itim_ctrl_out_type;

endpackage

import configure::*;
import itim_wires::*;

module itim_tag
(
  input logic clk,
  input itim_tag_in_type itim_tag_in,
  output itim_tag_out_type itim_tag_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [29-(itim_depth+itim_width):0] tag_array[0:2**itim_depth-1] = '{default:'0};

  assign itim_tag_out.rdata = tag_array[itim_tag_in.raddr];

  always_ff @(posedge clk) begin
    if (itim_tag_in.wen == 1) begin
      tag_array[itim_tag_in.waddr] <= itim_tag_in.wdata;
    end
  end

endmodule

module itim_data
(
  input logic clk,
  input itim_data_in_type itim_data_in,
  output itim_data_out_type itim_data_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [2**itim_width*32-1 : 0] data_array[0:2**itim_depth-1] = '{default:'0};

  assign itim_data_out.rdata = data_array[itim_data_in.raddr];

  always_ff @(posedge clk) begin
    if (itim_data_in.wen == 1) begin
      data_array[itim_data_in.waddr] <= itim_data_in.wdata;
    end
  end

endmodule

module itim_valid
(
  input logic clk,
  input itim_valid_in_type itim_valid_in,
  output itim_valid_out_type itim_valid_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0 : 0] valid_array[0:2**itim_depth-1] = '{default:'0};

  assign itim_valid_out.rdata = valid_array[itim_valid_in.raddr];

  always_ff @(posedge clk) begin
    if (itim_valid_in.wen == 1) begin
      valid_array[itim_valid_in.waddr] <= itim_valid_in.wdata;
    end
  end

endmodule

module itim_lock
(
  input logic clk,
  input itim_lock_in_type itim_lock_in,
  output itim_lock_out_type itim_lock_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0 : 0] lock_array[0:2**itim_depth-1] = '{default:'0};

  assign itim_lock_out.rdata = lock_array[itim_lock_in.raddr];

  always_ff @(posedge clk) begin
    if (itim_lock_in.wen == 1) begin
      lock_array[itim_lock_in.waddr] <= itim_lock_in.wdata;
    end
  end

endmodule

module itim_ctrl
(
  input logic rst,
  input logic clk,
  input itim_ctrl_in_type ictrl_in,
  output itim_ctrl_out_type ictrl_out,
  input mem_in_type itim_in,
  output mem_out_type itim_out,
  input mem_out_type imem_out,
  output mem_in_type imem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  parameter [2:0] hit = 0;
  parameter [2:0] miss = 1;
  parameter [2:0] load = 2;
  parameter [2:0] inv = 3;
  parameter [2:0] reset = 4;

  typedef struct packed{
    logic [29-(itim_depth+itim_width):0] tag;
    logic [2**itim_width*32-1:0] data;
    logic [itim_depth-1:0] did;
    logic [itim_width-1:0] wid;
    logic [itim_width-1:0] cnt;
    logic [31:0] addr;
    logic [31:0] rdata;
    logic [0:0] ready;
    logic [0:0] fence;
    logic [0:0] valid;
    logic [0:0] lock;
    logic [0:0] en;
    logic [0:0] upd;
    logic [0:0] inv;
    logic [0:0] wen;
    logic [0:0] hit;
    logic [0:0] miss;
    logic [0:0] load;
    logic [2:0] state;
  } back_type;

  parameter back_type init_reg = '{
    tag : 0,
    data : 0,
    did : 0,
    wid : 0,
    cnt : 0,
    addr : 0,
    rdata : 0,
    ready : 0,
    fence : 0,
    valid : 0,
    lock : 0,
    en : 0,
    upd: 0,
    inv : 0,
    wen : 0,
    hit : 0,
    miss : 0,
    load : 0,
    state : 0
  };

  back_type r,rin = init_reg;
  back_type v = init_reg;

  always_comb begin

    v = r;

    v.fence = 0;
    v.en = 0;
    v.upd = 0;
    v.inv = 0;
    v.hit = 0;
    v.miss = 0;
    v.load = 0;

    if (r.state == hit) begin
      if (itim_in.mem_valid == 1) begin
        if (itim_in.mem_fence == 1) begin
          v.fence = itim_in.mem_fence;
          v.en = itim_in.mem_valid;
          v.did = 0;
        end else begin
          v.en = itim_in.mem_valid;
          v.addr = itim_in.mem_addr;
          v.tag = itim_in.mem_addr[31:(itim_depth+itim_width+2)];
          v.did = itim_in.mem_addr[(itim_depth+itim_width+1):(itim_width+2)];
          v.wid = itim_in.mem_addr[(itim_width+1):2];
        end
      end
    end

    ictrl_out.tag_in.raddr = v.did;
    ictrl_out.data_in.raddr = v.did;
    ictrl_out.lock_in.raddr = v.did;
    // ictrl_out.valid_in.raddr = v.did;

    case(r.state)
      hit :
        begin

          v.wen = 0;
          v.lock = ictrl_in.lock_out.rdata;

          if (v.fence == 1) begin
            v.inv = v.en;
          end else if (v.addr < itim_base_addr || v.addr >= itim_top_addr) begin
            v.load = v.en;
          end else if (v.lock == 0) begin
            v.miss = v.en;
          end else if (|(ictrl_in.tag_out.rdata ^ v.tag) == 1) begin
            v.load = v.en;
          end else begin
            v.hit = v.en;
          end

          if (v.inv == 1) begin
            v.state = inv;
            v.valid = 0;
          end else if (v.miss == 1) begin
            v.state = miss;
            v.addr[itim_width+1:0] = 0;
            v.cnt = 0;
            v.valid = 1;
          end else if (v.load == 1) begin
            v.state = load;
            v.valid = 1;
          end else begin
            v.data = ictrl_in.data_out.rdata;
            v.valid = 0;
          end

        end
      miss :
        begin

          v.wen = 0;
          v.lock = 0;

          if (imem_out.mem_ready == 1) begin
            v.data[32*v.cnt +: 32] = imem_out.mem_rdata;
            if (v.cnt == 2*itim_width-1) begin
              v.upd = 1;
              v.wen = 1;
              v.lock = 1;
              v.valid = 0;
              v.state = hit;
            end else begin
              v.addr = v.addr + 4;
              v.cnt = v.cnt + 1;
            end
          end

        end
      load :
        begin

          v.wen = 0;
          v.lock = 0;

          if (imem_out.mem_ready == 1) begin
            v.state = hit;
            v.valid = 0;
          end

        end
      inv :
        begin

          v.wen = 1;
          v.lock = 0;
          v.valid = 0;
          v.inv = 1;

        end
      default :
        begin

        end
    endcase

    ictrl_out.tag_in.waddr = v.did;
    ictrl_out.tag_in.wen = v.wen;
    ictrl_out.tag_in.wdata = v.tag;

    ictrl_out.data_in.waddr = v.did;
    ictrl_out.data_in.wen = v.wen;
    ictrl_out.data_in.wdata = v.data;

    ictrl_out.lock_in.waddr = v.did;
    ictrl_out.lock_in.wen = v.wen | v.inv;
    ictrl_out.lock_in.wdata = v.lock;

    // ictrl_out.valid_in.waddr = v.did;
    // ictrl_out.valid_in.wen = v.wen or v.inv;
    // ictrl_out.valid_in.wdata = v.valid;

    if (v.state == inv) begin
      if (v.did == 2**itim_depth-1) begin
        v.state = hit;
      end else begin
        v.did = v.did + 1;
      end
    end

    case(r.state)
      hit :
        begin
          v.rdata = v.data[32*v.wid +: 32];
          v.ready = v.en & v.hit;
        end
      miss :
        begin
          v.rdata = v.data[32*v.wid +: 32];
          v.ready = v.upd;
        end
      load :
        begin
          v.rdata = imem_out.mem_rdata;
          v.ready = imem_out.mem_ready;
        end
      inv :
        begin
          if (v.state == hit) begin
            v.rdata = 0;
            v.ready = 1;
          end else begin
            v.rdata = 0;
            v.ready = 0;
          end
        end
      default :
        begin
          v.rdata = 0;
          v.ready = 0;
        end
    endcase

    imem_in.mem_valid = v.valid;
    imem_in.mem_fence = 0;
    imem_in.mem_instr = 1;
    imem_in.mem_addr = v.addr;
    imem_in.mem_wdata = 0;
    imem_in.mem_wstrb = 0;

    rin = v;

    itim_out.mem_rdata = r.rdata;
    itim_out.mem_ready = r.ready;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

endmodule

module itim
#(
  parameter itim_enable = 1
)
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

  generate

    if (itim_enable == 1) begin

      itim_ctrl_in_type ictrl_in;
      itim_ctrl_out_type ictrl_out;

      itim_tag itim_tag_comp
      (
        .clk (clk),
        .itim_tag_in (ictrl_out.tag_in),
        .itim_tag_out (ictrl_in.tag_out)
      );

      itim_data itim_data_comp
      (
        .clk (clk),
        .itim_data_in (ictrl_out.data_in),
        .itim_data_out (ictrl_in.data_out)
      );

      itim_valid itim_valid_comp
      (
        .clk (clk),
        .itim_valid_in (ictrl_out.valid_in),
        .itim_valid_out (ictrl_in.valid_out)
      );

      itim_lock itim_lock_comp
      (
        .clk (clk),
        .itim_lock_in (ictrl_out.lock_in),
        .itim_lock_out (ictrl_in.lock_out)
      );

      itim_ctrl itim_ctrl_comp
      (
        .rst (rst),
        .clk (clk),
        .ictrl_in (ictrl_in),
        .ictrl_out (ictrl_out),
        .itim_in (itim_in),
        .itim_out (itim_out),
        .imem_out (imem_out),
        .imem_in (imem_in)
      );

    end else begin

      assign imem_in = itim_in;
      assign itim_out = imem_out;

    end

  endgenerate

endmodule
