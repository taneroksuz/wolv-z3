package dtim_wires;
  timeunit 1ns;
  timeprecision 1ps;

  import configure::*;

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
    logic [0 : 0] wen;
    logic [dtim_depth-1 : 0] waddr;
    logic [dtim_depth-1 : 0] raddr;
    logic [0 : 0] wdata;
  } dtim_dirty_in_type;

  typedef struct packed{
    logic [0 : 0] rdata;
  } dtim_dirty_out_type;

  typedef struct packed{
    dtim_tag_out_type tag_out;
    dtim_data_out_type data_out;
    dtim_valid_out_type valid_out;
    dtim_lock_out_type lock_out;
    dtim_dirty_out_type dirty_out;
  } dtim_ctrl_in_type;

  typedef struct packed{
    dtim_tag_in_type tag_in;
    dtim_data_in_type data_in;
    dtim_valid_in_type valid_in;
    dtim_lock_in_type lock_in;
    dtim_dirty_in_type dirty_in;
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

  logic [29-(dtim_depth+dtim_width):0] tag_array[0:2**dtim_depth-1] = '{default:'0};

  assign dtim_tag_out.rdata = tag_array[dtim_tag_in.raddr];

  always_ff @(posedge clk) begin
    if (dtim_tag_in.wen == 1) begin
      tag_array[dtim_tag_in.waddr] <= dtim_tag_in.wdata;
    end
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

  logic [2**dtim_width*32-1 : 0] data_array[0:2**dtim_depth-1] = '{default:'0};

  assign dtim_data_out.rdata = data_array[dtim_data_in.raddr];

  always_ff @(posedge clk) begin
    if (dtim_data_in.wen == 1) begin
      data_array[dtim_data_in.waddr] <= dtim_data_in.wdata;
    end
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

  logic [0 : 0] valid_array[0:2**dtim_depth-1] = '{default:'0};

  assign dtim_valid_out.rdata = valid_array[dtim_valid_in.raddr];

  always_ff @(posedge clk) begin
    if (dtim_valid_in.wen == 1) begin
      valid_array[dtim_valid_in.waddr] <= dtim_valid_in.wdata;
    end
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

  logic [0 : 0] lock_array[0:2**dtim_depth-1] = '{default:'0};

  assign dtim_lock_out.rdata = lock_array[dtim_lock_in.raddr];

  always_ff @(posedge clk) begin
    if (dtim_lock_in.wen == 1) begin
      lock_array[dtim_lock_in.waddr] <= dtim_lock_in.wdata;
    end
  end

endmodule

module dtim_dirty
(
  input logic clk,
  input dtim_dirty_in_type dtim_dirty_in,
  output dtim_dirty_out_type dtim_dirty_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0 : 0] dirty_array[0:2**dtim_depth-1] = '{default:'0};
  logic [0 : 0] dirty_rdata = 0;

  assign dtim_dirty_out.rdata = dirty_rdata;

  always_ff @(posedge clk) begin
    if (dtim_dirty_in.wen == 1) begin
      dirty_array[dtim_dirty_in.waddr] <= dtim_dirty_in.wdata;
    end
    dirty_rdata <= dirty_array[dtim_dirty_in.raddr];
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
  parameter [2:0] ldst = 2;
  parameter [2:0] inv = 3;
  parameter [2:0] reset = 4;

  typedef struct packed{
    logic [29-(dtim_depth+dtim_width):0] tag;
    logic [2**dtim_width*32-1:0] data;
    logic [dtim_depth-1:0] did;
    logic [dtim_width-1:0] wid;
    logic [dtim_width-1:0] cnt;
    logic [31:0] addr;
    logic [3:0] strb;
    logic [3:0] wstrb;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic [31:0] sdata;
    logic [0:0] ready;
    logic [0:0] fence;
    logic [0:0] valid;
    logic [0:0] lock;
    logic [0:0] dirty;
    logic [0:0] wren;
    logic [0:0] rden;
    logic [0:0] upd;
    logic [0:0] inv;
    logic [0:0] store;
    logic [0:0] wen;
    logic [0:0] hit;
    logic [0:0] miss;
    logic [0:0] ldst;
    logic [2:0] state;
  } back_type;

  parameter back_type init_reg = '{
    tag : 0,
    data : 0,
    did : 0,
    wid : 0,
    cnt : 0,
    addr : 0,
    strb : 0,
    wdata : 0,
    sdata : 0,
    wstrb : 0,
    rdata : 0,
    ready : 0,
    fence : 0,
    valid : 0,
    lock : 0,
    dirty : 0,
    wren : 0,
    rden : 0,
    upd: 0,
    inv : 0,
    store : 0,
    wen : 0,
    hit : 0,
    miss : 0,
    ldst : 0,
    state : 0
  };

  integer i;

  back_type r,rin = init_reg;
  back_type v = init_reg;

  always_comb begin

    v = r;

    v.fence = 0;
    v.rden = 0;
    v.wren = 0;
    v.upd = 0;
    v.inv = 0;
    v.hit = 0;
    v.miss = 0;
    v.ldst = 0;
    v.wstrb = 0;

    if (r.state == hit) begin
      if (dtim_in.mem_valid == 1) begin
        if (dtim_in.mem_fence == 1) begin
          v.fence = dtim_in.mem_fence;
          v.wren = dtim_in.mem_valid;
          v.did = 0;
        end else begin
          v.wren = |dtim_in.mem_wstrb;
          v.rden = ~(|dtim_in.mem_wstrb);
          v.wdata = dtim_in.mem_wdata;
          v.strb = dtim_in.mem_wstrb;
          v.addr = dtim_in.mem_addr;
          v.tag = dtim_in.mem_addr[31:(dtim_depth+dtim_width+2)];
          v.did = dtim_in.mem_addr[(dtim_depth+dtim_width+1):(dtim_width+2)];
          v.wid = dtim_in.mem_addr[(dtim_width+1):2];
          v.store = v.wren;
        end
      end
    end

    dctrl_out.tag_in.raddr = v.did;
    dctrl_out.data_in.raddr = v.did;
    dctrl_out.lock_in.raddr = v.did;
    dctrl_out.dirty_in.raddr = v.did;
    // dctrl_out.valid_in.raddr = v.did;

    case(r.state)
      hit :
        begin

          v.wen = 0;
          v.lock = dctrl_in.lock_out.rdata;
          v.dirty = dctrl_in.dirty_out.rdata;

          if (v.fence == 1) begin
            v.inv = v.wren;
          end else if (v.addr < dtim_base_addr || v.addr >= dtim_top_addr) begin
            v.ldst = v.wren | v.rden;
          end else if (v.lock == 0) begin
            v.miss = v.wren | v.rden;
          end else if (|(dctrl_in.tag_out.rdata ^ v.tag) == 1) begin
            v.ldst = v.wren | v.rden;
          end else begin
            v.hit = v.wren | v.rden;
          end

          if (v.inv == 1) begin
            v.state = inv;
            v.valid = 0;
          end else if (v.miss == 1) begin
            v.state = miss;
            v.addr[dtim_width+1:0] = 0;
            v.cnt = 0;
            v.valid = 1;
          end else if (v.ldst == 1) begin
            v.state = ldst;
            v.wstrb = v.strb;
            v.valid = 1;
          end else begin
            v.state = hit;
            v.data = dctrl_in.data_out.rdata;
            v.wen = v.wren;
            v.lock = v.wren;
            v.dirty = v.wren;
            v.valid = 0;
          end

        end
      miss :
        begin

          v.wen = 0;
          v.lock = 0;
          v.dirty = 0;

          if (dmem_out.mem_ready == 1) begin
            v.data[32*v.cnt +: 32] = dmem_out.mem_rdata;
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
      ldst :
        begin

          v.wen = 0;
          v.lock = 0;
          v.dirty = 0;

          if (dmem_out.mem_ready == 1) begin
            v.valid = 0;
            v.state = hit;
          end

        end
      inv :
        begin

          v.wen = 1;
          v.lock = 0;
          v.dirty = 0;
          v.valid = 0;
          v.inv = 1;

        end
      default :
        begin

        end
    endcase

    if (v.store == 1) begin
      v.sdata = v.data[32*v.wid +: 32];
      for (i=0; i<4; i=i+1) begin
        if (v.strb[i] == 1) begin
          v.sdata[8*i +: 8] = v.wdata[8*i +: 8];
        end
      end
      v.data[32*v.wid +: 32] = v.sdata;
    end

    dctrl_out.tag_in.waddr = v.did;
    dctrl_out.tag_in.wen = v.wen;
    dctrl_out.tag_in.wdata = v.tag;

    dctrl_out.data_in.waddr = v.did;
    dctrl_out.data_in.wen = v.wen;
    dctrl_out.data_in.wdata = v.data;

    dctrl_out.lock_in.waddr = v.did;
    dctrl_out.lock_in.wen = v.wen | v.inv;
    dctrl_out.lock_in.wdata = v.lock;

    dctrl_out.dirty_in.waddr = v.did;
    dctrl_out.dirty_in.wen = v.wen;
    dctrl_out.dirty_in.wdata = v.dirty;

    // dctrl_out.valid_in.waddr = v.did;
    // dctrl_out.valid_in.wen = v.wen or v.inv;
    // dctrl_out.valid_in.wdata = v.valid;

    if (v.state == inv) begin
      if (v.did == 2**dtim_depth-1) begin
        v.state = hit;
      end else begin
        v.did = v.did + 1;
      end
    end

    case(r.state)
      hit :
        begin
          v.rdata = v.data[32*v.wid +: 32];
          v.ready = (v.wren | v.rden) & v.hit;
        end
      miss :
        begin
          v.rdata = v.data[32*v.wid +: 32];
          v.ready = v.upd;
        end
      ldst :
        begin
          v.rdata = dmem_out.mem_rdata;
          v.ready = dmem_out.mem_ready;
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

    dmem_in.mem_valid = v.valid;
    dmem_in.mem_fence = 0;
    dmem_in.mem_instr = 1;
    dmem_in.mem_addr = v.addr;
    dmem_in.mem_wdata = v.wdata;
    dmem_in.mem_wstrb = v.wstrb;

    rin = v;

    dtim_out.mem_rdata = r.rdata;
    dtim_out.mem_ready = r.ready;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
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

      dtim_dirty dtim_dirty_comp
      (
        .clk (clk),
        .dtim_dirty_in (dctrl_out.dirty_in),
        .dtim_dirty_out (dctrl_in.dirty_out)
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
