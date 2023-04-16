import constants::*;
import functions::*;
import wires::*;

module fetch_stage
(
  input logic reset,
  input logic clock,
  input csr_out_type csr_out,
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

    v.valid = ~d.e.clear;

    if (csr_out.trap == 1) begin
      v.spec = 1;
      v.pc = csr_out.mtvec;
    end else if (csr_out.mret == 1) begin
      v.spec = 1;
      v.pc = csr_out.mepc;
    end else if (d.d.jump == 1) begin
      v.spec = 1;
      v.pc = d.d.address;
    end else if (d.d.fence == 1) begin
      v.spec = 1;
      v.pc = d.d.npc;
    end else if ((v.stall | a.d.stall | a.e.stall) == 0) begin
      v.spec = 0;
      v.pc = a.d.npc;
    end

    imem_in.mem_valid = v.valid;
    imem_in.mem_fence = d.d.fence;
    imem_in.mem_spec = v.spec;
    imem_in.mem_instr = 1;
    imem_in.mem_addr = v.pc;
    imem_in.mem_wdata = 0;
    imem_in.mem_wstrb = 0;

    rin = v;

    y.pc = v.pc;

    q.pc = r.pc;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_fetch_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
