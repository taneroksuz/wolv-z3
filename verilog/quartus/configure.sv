package configure;
  timeunit 1ns;
  timeprecision 1ps;

  parameter buffer_depth = 8;

  parameter tim_width = 32;
  parameter tim_depth = 128;

  parameter rom_base_addr = 32'h0;
  parameter rom_top_addr  = 32'h80;

  parameter uart_base_addr = 32'h1000000;
  parameter uart_top_addr  = 32'h1000004;

  parameter clint_base_addr = 32'h2000000;
  parameter clint_top_addr  = 32'h200C000;

  parameter avl_base_addr = 32'h80000000;
  parameter avl_top_addr  = 32'h90000000;

  parameter itim_base_addr = 32'h10000000;
  parameter itim_top_addr  = 32'h10004000;

  parameter dtim_base_addr = 32'h20000000;
  parameter dtim_top_addr  = 32'h20004000;

  parameter clk_freq = 25000000; // 25MHz
  parameter rtc_freq = 32768; // 32768Hz
  parameter baudrate = 115200;

  parameter clk_divider_rtc = (clk_freq/rtc_freq)/2-1;
  parameter clks_per_bit = clk_freq/baudrate-1;

endpackage
