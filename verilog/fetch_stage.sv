import constants::*;
import functions::*;
import wires::*;

module fetch_stage
(
  input logic reset,
  input logic clock,
  input buffer_out_type buffer_out,
  output buffer_in_type buffer_in,
  input csr_out_type csr_out,
  input mem_out_type imem_out,
  output mem_in_type imem_in,
  input fetch_in_type a,
  input fetch_in_type d,
  output fetch_out_type y,
  output fetch_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  fetch_reg_type r,rin;
  fetch_reg_type v;

  always_comb begin

    v = r;

    v.valid = 0;
    v.stall = buffer_out.stall;

    v.fence = 0;
    v.spec = 0;
    
    v.rdata = imem_out.mem_rdata;
    v.ready = imem_out.mem_ready;

    v.pc = buffer_out.pc;
    v.instr = buffer_out.instr;
    v.ready = buffer_out.ready;

    if (csr_out.trap == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.pc = csr_out.mtvec;
    end else if (csr_out.mret == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.pc = csr_out.mepc;
    end else if (d.d.jump == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.pc = d.d.address;
    end else if (d.e.fence == 1) begin
      v.fence = 1;
      v.spec = 1;
      v.pc = d.e.npc;
    end else if (v.stall == 0) begin
      v.fence = 0;
      v.spec = 0;
      v.pc = v.pc + 4;
    end

    buffer_in.pc = {r.pc[31:2],2'b00};
    buffer_in.rdata = v.rdata;
    buffer_in.ready = v.ready;
    buffer_in.align = v.pc[1];
    buffer_in.clear = v.spec;
    buffer_in.stall = a.d.stall | a.e.stall;

    imem_in.mem_valid = v.valid;
    imem_in.mem_fence = v.fence;
    imem_in.mem_spec = v.spec;
    imem_in.mem_instr = 1;
    imem_in.mem_addr = v.pc;
    imem_in.mem_wdata = 0;
    imem_in.mem_wstrb = 0;

    rin = v;

    y.pc = v.pc;
    y.instr = v.instr;
    y.ready = v.ready;

    q.pc = r.pc;
    q.instr = r.instr;
    q.ready = r.ready;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_fetch_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
