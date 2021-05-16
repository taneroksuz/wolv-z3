import wires::*;

module cpu
(
  input logic rst,
  input logic clk,
  output logic [0  : 0] imemory_valid,
  output logic [0  : 0] imemory_instr,
  output logic [31 : 0] imemory_addr,
  output logic [31 : 0] imemory_wdata,
  output logic [3  : 0] imemory_wstrb,
  input logic [31  : 0] imemory_rdata,
  input logic [0   : 0] imemory_ready,
  output logic [0  : 0] dmemory_valid,
  output logic [0  : 0] dmemory_instr,
  output logic [31 : 0] dmemory_addr,
  output logic [31 : 0] dmemory_wdata,
  output logic [3  : 0] dmemory_wstrb,
  input logic [31  : 0] dmemory_rdata,
  input logic [0   : 0] dmemory_ready,
  input logic [0   :0] extern_irpt,
  input logic [0   :0] timer_irpt,
  input logic [0   :0] soft_irpt
);
  timeunit 1ns;
  timeprecision 1ps;

  agu_in_type agu_in;
  agu_out_type agu_out;
  alu_in_type alu_in;
  alu_out_type alu_out;
  bcu_in_type bcu_in;
  bcu_out_type bcu_out;
  lsu_in_type lsu_in;
  lsu_out_type lsu_out;
  csr_alu_in_type csr_alu_in;
  csr_alu_out_type csr_alu_out;
  mul_in_type mul_in;
  mul_out_type mul_out;
  div_in_type div_in;
  div_out_type div_out;
  decoder_in_type decoder_in;
  decoder_out_type decoder_out;
  compress_in_type compress_in;
  compress_out_type compress_out;
  forwarding_register_in_type forwarding_rin;
  forwarding_execute_in_type forwarding_ein;
  forwarding_out_type forwarding_out;
  csr_decode_in_type csr_din;
  csr_execute_in_type csr_ein;
  csr_out_type csr_out;
  register_read_in_type register_rin;
  register_write_in_type register_win;
  register_out_type register_out;
  fetch_in_type fetch_in;
  decode_in_type decode_in;
  execute_in_type execute_in;
  fetch_out_type fetch_out;
  decode_out_type decode_out;
  execute_out_type execute_out;
  prefetch_in_type prefetch_in;
  prefetch_out_type prefetch_out;
  mem_in_type imem_in;
  mem_out_type imem_out;
  mem_in_type dmem_in;
  mem_out_type dmem_out;

  assign fetch_in.f = fetch_out;
  assign fetch_in.d = decode_out;
  assign fetch_in.e = execute_out;
  assign decode_in.f = fetch_out;
  assign decode_in.d = decode_out;
  assign decode_in.e = execute_out;
  assign execute_in.f = fetch_out;
  assign execute_in.d = decode_out;
  assign execute_in.e = execute_out;

  agu agu_comp
  (
    .agu_in (agu_in),
    .agu_out (agu_out)
  );

  alu alu_comp
  (
    .alu_in (alu_in),
    .alu_out (alu_out)
  );

  bcu bcu_comp
  (
    .bcu_in (bcu_in),
    .bcu_out (bcu_out)
  );

  lsu lsu_comp
  (
    .lsu_in (lsu_in),
    .lsu_out (lsu_out)
  );

  csr_alu csr_alu_comp
  (
    .csr_alu_in (csr_alu_in),
    .csr_alu_out (csr_alu_out)
  );

  div div_comp
  (
    .rst (rst),
    .clk (clk),
    .div_in (div_in),
    .div_out (div_out)
  );

  mul mul_comp
  (
    .rst (rst),
    .clk (clk),
    .mul_in (mul_in),
    .mul_out (mul_out)
  );

  forwarding forwarding_comp
  (
    .forwarding_rin (forwarding_rin),
    .forwarding_ein (forwarding_ein),
    .forwarding_out (forwarding_out)
  );

  decoder decoder_comp
  (
    .decoder_in (decoder_in),
    .decoder_out (decoder_out)
  );

  compress compress_comp
  (
    .compress_in (compress_in),
    .compress_out (compress_out)
  );

  register register_comp
  (
    .rst (rst),
    .clk (clk),
    .register_rin (register_rin),
    .register_win (register_win),
    .register_out (register_out)
  );

  csr csr_comp
  (
    .rst (rst),
    .clk (clk),
    .csr_din (csr_din),
    .csr_ein (csr_ein),
    .csr_out (csr_out),
    .extern_irpt (extern_irpt),
    .timer_irpt (timer_irpt),
    .soft_irpt (soft_irpt)
  );

  prefetch prefetch_comp
  (
    .rst (rst),
    .clk (clk),
    .prefetch_in (prefetch_in),
    .prefetch_out (prefetch_out)
  );

  fetch_stage fetch_stage_comp
  (
    .rst (rst),
    .clk (clk),
    .csr_out (csr_out),
    .prefetch_out (prefetch_out),
    .prefetch_in (prefetch_in),
    .imem_out (imem_out),
    .imem_in (imem_in),
    .d (fetch_in),
    .q (fetch_out)
  );

  decode_stage decode_stage_comp
  (
    .rst (rst),
    .clk (clk),
    .decoder_out (decoder_out),
    .decoder_in (decoder_in),
    .compress_out (compress_out),
    .compress_in (compress_in),
    .agu_out (agu_out),
    .agu_in (agu_in),
    .bcu_out (bcu_out),
    .bcu_in (bcu_in),
    .register_out (register_out),
    .register_rin (register_rin),
    .forwarding_out (forwarding_out),
    .forwarding_rin (forwarding_rin),
    .csr_out (csr_out),
    .csr_din (csr_din),
    .dmem_in (dmem_in),
    .d (decode_in),
    .q (decode_out)
  );

  execute_stage execute_stage_comp
  (
    .rst (rst),
    .clk (clk),
    .alu_out (alu_out),
    .alu_in (alu_in),
    .lsu_out (lsu_out),
    .lsu_in (lsu_in),
    .csr_alu_out (csr_alu_out),
    .csr_alu_in (csr_alu_in),
    .mul_out (mul_out),
    .mul_in (mul_in),
    .div_out (div_out),
    .div_in (div_in),
    .register_win (register_win),
    .forwarding_ein (forwarding_ein),
    .csr_out (csr_out),
    .csr_ein (csr_ein),
    .dmem_out (dmem_out),
    .d (execute_in),
    .q (execute_out)
  );


  assign imemory_valid = imem_in.mem_valid;
  assign imemory_instr = imem_in.mem_instr;
  assign imemory_addr = imem_in.mem_addr;
  assign imemory_wdata = imem_in.mem_wdata;
  assign imemory_wstrb = imem_in.mem_wstrb;
  assign imem_out.mem_rdata = imemory_rdata;
  assign imem_out.mem_ready = imemory_ready;

  assign dmemory_valid = dmem_in.mem_valid;
  assign dmemory_instr = dmem_in.mem_instr;
  assign dmemory_addr = dmem_in.mem_addr;
  assign dmemory_wdata = dmem_in.mem_wdata;
  assign dmemory_wstrb = dmem_in.mem_wstrb;
  assign dmem_out.mem_rdata = dmemory_rdata;
  assign dmem_out.mem_ready = dmemory_ready;

endmodule
