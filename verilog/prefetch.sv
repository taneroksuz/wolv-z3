import configure::*;
import constants::*;
import wires::*;

module prefetch
(
  input logic rst,
  input logic clk,
  input mem_in_type prefetch_in,
  output mem_out_type prefetch_out,
  input mem_out_type imem_out,
  output mem_in_type imem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [62 : 0] prefetch_buffer[0:2**prefetch_depth-1] = '{default:'0};

  typedef struct packed{
    logic [2*prefetch_depth-1:0] incr;
    logic [2*prefetch_depth-1:0] step;
    logic [prefetch_depth-1:0] wid;
    logic [prefetch_depth-1:0] rid1;
    logic [prefetch_depth-1:0] rid2;
    logic [62:0] wdata;
    logic [62:0] rdata1;
    logic [62:0] rdata2;
    logic [0:0] pwren;
    logic [0:0] wren;
    logic [0:0] rden1;
    logic [0:0] rden2;
    logic [31:0] paddr;
    logic [31:0] addr;
    logic [0:0] pfence;
    logic [0:0] fence;
    logic [0:0] valid;
    logic [31:0] rdata;
    logic [0:0] ready;
    logic [0:0] stall;
  } reg_type;

  reg_type init_reg = '{
    incr : 0,
    step : 0,
    wid : 0,
    rid1 : 0,
    rid2 : 0,
    wdata : 0,
    rdata1 : 0,
    rdata2 : 0,
    pwren : 0,
    wren : 0,
    rden1 : 0,
    rden2 : 0,
    paddr : 0,
    addr : 0,
    pfence : 0,
    fence : 0,
    valid : 0,
    rdata : 0,
    ready : 0,
    stall : 0
  };

  reg_type r,rin;
  reg_type v;

  always_comb begin

    v = r;

    v.valid = 1;

    v.ready = 0;
    v.rdata = 0;

    v.rden1 = 0;
    v.rden2 = 0;

    v.rdata1 = 0;
    v.rdata2 = 0;

    v.wren = 0;

    if (imem_out.mem_ready == 1) begin
      v.wren = 1;
      v.wid = v.addr[(prefetch_depth+1):2];
      v.wdata = {v.wren,v.addr[31:2],imem_out.mem_rdata};
    end

    if (v.wren == 1) begin
      if (v.incr < 2**prefetch_depth-1) begin
        v.incr = v.incr + 2;
        v.addr = v.addr + 4;
      end else begin
        v.valid = 0;
      end
    end

    if (prefetch_in.mem_valid == 1) begin
      v.pfence = prefetch_in.mem_fence;
      v.paddr = prefetch_in.mem_addr;
    end

    v.rid1 = v.paddr[prefetch_depth+1:2];

    if (v.rid1 == 2**prefetch_depth-1) begin
      v.rid2 = 0;
    end else begin
      v.rid2 = v.paddr[prefetch_depth+1:2]+1;
    end

    v.pwren = v.wren;

    v.rdata1 = prefetch_buffer[v.rid1];
    v.rdata2 = prefetch_buffer[v.rid2];

    if (v.rdata1[62] == 1 && v.rdata1[61:32] == v.paddr[31:2]) begin
      v.rden1 = 1;
    end
    if (v.rdata2[62] == 1 && v.rdata2[61:32] == (v.paddr[31:2]+1)) begin
      v.rden2 = 1;
    end

    if (v.wren == 1) begin
      if (v.rden1 == 0) begin
        v.addr = {v.paddr[31:2],2'b0};
      end else if (v.rden2 == 0) begin
        v.addr = {(v.paddr[31:2]+30'b1),2'b0};
      end
    end

    if (v.rden1 == 0) begin
      v.incr = 0;
    end else if (v.rden2 == 0) begin
      if (v.paddr[1:1] == 0) begin
        v.rdata = v.rdata1[31:0];
        v.ready = 1;
      end else if (v.rdata1[17:16] < 3) begin
        v.rdata = {16'h0,v.rdata1[31:16]};
        v.ready = 1;
      end
    end else begin
      if (v.paddr[1:1] == 0) begin
        v.rdata = v.rdata1[31:0];
        v.ready = 1;
      end else begin
        v.rdata = {v.rdata2[15:0],v.rdata1[31:16]};
        v.ready = 1;
      end
    end

    if (v.ready == 0) begin
      v.step = 0;
    end else if (v.rdata[1:0] < 3) begin
      v.step = 1;
    end else begin
      v.step = 2;
    end

    if (v.step <= v.incr) begin
      v.incr = v.incr - v.step;
    end

    imem_in.mem_valid = v.valid;
    imem_in.mem_fence = v.fence;
    imem_in.mem_instr = 1;
    imem_in.mem_addr = v.addr;
    imem_in.mem_wdata = 0;
    imem_in.mem_wstrb = 0;

    rin = v;

    prefetch_out.mem_rdata = r.rdata;
    prefetch_out.mem_ready = r.ready;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_reg;
    end else begin
      r <= rin;
    end
  end

  always_ff @(posedge clk) begin
    if (rin.pwren == 1) begin
      prefetch_buffer[rin.wid] <= rin.wdata;
    end
  end

endmodule
