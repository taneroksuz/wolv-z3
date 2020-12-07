package configure;
	timeunit 1ns;
	timeprecision 1ps;

	parameter iram_base_addr = 32'h0;
	parameter iram_top_addr = 32'h20000;

	parameter dram_base_addr = 32'h20000;
	parameter dram_top_addr = 32'h40000;

	parameter uart_base_addr = 32'h100000;
	parameter uart_top_addr = 32'h100004;

	parameter timer_base_addr = 32'h200000;
	parameter timer_top_addr = 32'h200010;

	parameter prefetch_depth = 4;
	parameter iram_depth = 15;
	parameter dram_depth = 15;

endpackage
