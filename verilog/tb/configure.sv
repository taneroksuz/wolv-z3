package configure;

  timeunit 1ns;
  timeprecision 1ps;

  parameter prefetch_depth = 4;

  parameter iram_depth = 16;

  parameter dram_depth = 16;

  parameter clint_contexts = 0;

  parameter plic_contexts = 0;

  parameter iram_base_addr = 32'h0;
  parameter iram_top_addr = 32'h40000;

  parameter dram_base_addr = 32'h40000;
  parameter dram_top_addr = 32'h80000;

  parameter uart_base_addr = 32'h1000000;
  parameter uart_top_addr  = 32'h1000004;

  parameter clint_base_addr = 32'h2000000;
  parameter clint_top_addr  = 32'h200C000;

  parameter plic_base_addr = 32'h0C000000;
  parameter plic_top_addr  = 32'h10000000;

endpackage
