import configure::*;

module soc
(
  input logic rst,
  input logic clk,
  input logic rx,
  output logic tx
);
  timeunit 1ns;
  timeprecision 1ps;

  logic rtc;
  logic rst_pll;
  logic clk_pll;
  logic locked;

  logic [0  : 0] imemory_valid;
  logic [0  : 0] imemory_instr;
  logic [31 : 0] imemory_addr;
  logic [31 : 0] imemory_wdata;
  logic [3  : 0] imemory_wstrb;
  logic [31 : 0] imemory_rdata;
  logic [0  : 0] imemory_ready;

  logic [0  : 0] dmemory_valid;
  logic [0  : 0] dmemory_instr;
  logic [31 : 0] dmemory_addr;
  logic [31 : 0] dmemory_wdata;
  logic [3  : 0] dmemory_wstrb;
  logic [31 : 0] dmemory_rdata;
  logic [0  : 0] dmemory_ready;

  logic [0  : 0] iram_valid;
  logic [0  : 0] iram_wen;
  logic [0  : 0] iram_instr;
  logic [31 : 0] iram_addr;
  logic [31 : 0] iram_wdata;
  logic [3  : 0] iram_wstrb;
  logic [31 : 0] iram_rdata;
  logic [0  : 0] iram_ready;

  logic [0  : 0] dram_valid;
  logic [0  : 0] dram_wen;
  logic [0  : 0] dram_instr;
  logic [31 : 0] dram_addr;
  logic [31 : 0] dram_wdata;
  logic [3  : 0] dram_wstrb;
  logic [31 : 0] dram_rdata;
  logic [0  : 0] dram_ready;

  logic [0  : 0] uart_valid;
  logic [0  : 0] uart_instr;
  logic [31 : 0] uart_addr;
  logic [31 : 0] uart_wdata;
  logic [3  : 0] uart_wstrb;
  logic [31 : 0] uart_rdata;
  logic [0  : 0] uart_ready;

  logic [0  : 0] timer_valid;
  logic [0  : 0] timer_instr;
  logic [31 : 0] timer_addr;
  logic [31 : 0] timer_wdata;
  logic [3  : 0] timer_wstrb;
  logic [31 : 0] timer_rdata;
  logic [0  : 0] timer_ready;
  logic [0  : 0] timer_irpt;

  logic [0  : 0] iram_i;
  logic [0  : 0] iram_d;
  logic [0  : 0] dram_i;
  logic [0  : 0] dram_d;
  logic [0  : 0] uart_i;
  logic [0  : 0] uart_d;
  logic [0  : 0] timer_i;
  logic [0  : 0] timer_d;

  parameter [2  : 0] iram_access = 0;
  parameter [2  : 0] dram_access = 1;
  parameter [2  : 0] uart_access = 2;
  parameter [2  : 0] timer_access = 3;
  parameter [2  : 0] non_access = 4;

  logic [2  : 0] instr_access_type;
  logic [2  : 0] instr_release_type;

  logic [2  : 0] data_access_type;
  logic [2  : 0] data_release_type;

  always_comb begin

    if (dmemory_addr >= timer_base_addr &&
      dmemory_addr < timer_top_addr) begin
        timer_d = dmemory_valid;
        uart_d = 0;
        dram_d = 0;
        iram_d = 0;
    end else if (dmemory_addr >= uart_base_addr &&
      dmemory_addr < uart_top_addr) begin
        timer_d = 0;
        uart_d = dmemory_valid;
        dram_d = 0;
        iram_d = 0;
    end else if (dmemory_addr >= dram_base_addr &&
      dmemory_addr < dram_top_addr) begin
        timer_d = 0;
        uart_d = 0;
        dram_d = dmemory_valid;
        iram_d = 0;
    end else if (dmemory_addr >= iram_base_addr &&
      dmemory_addr < iram_top_addr) begin
        timer_d = 0;
        uart_d = 0;
        dram_d = 0;
        iram_d = dmemory_valid;
    end else begin
      timer_d = 0;
      uart_d = 0;
      dram_d = 0;
      iram_d = 0;
    end

    if (imemory_addr >= timer_base_addr &&
      imemory_addr < timer_top_addr) begin
        timer_i = imemory_valid;
        uart_i = 0;
        dram_i = 0;
        iram_i = 0;
    end else if (imemory_addr >= uart_base_addr &&
      imemory_addr < uart_top_addr) begin
        timer_i = 0;
        uart_i = imemory_valid;
        dram_i = 0;
        iram_i = 0;
    end else if (imemory_addr >= dram_base_addr &&
      imemory_addr < dram_top_addr) begin
        timer_i = 0;
        uart_i = 0;
        dram_i = imemory_valid;
        iram_i = 0;
    end else if (imemory_addr >= iram_base_addr &&
      imemory_addr < iram_top_addr) begin
        timer_i = 0;
        uart_i = 0;
        dram_i = 0;
        iram_i = imemory_valid;
    end else begin
      timer_i = 0;
      uart_i = 0;
      dram_i = 0;
      iram_i = 0;
    end

    if (timer_d==1 & timer_i==1) begin
      timer_valid = 1;
      uart_valid = 0;
      dram_valid = 0;
      iram_valid = 0;
      instr_access_type = non_access;
      data_access_type = timer_access;
    end else if (uart_d==1 & uart_i==1) begin
      timer_valid = 0;
      uart_valid = 1;
      dram_valid = 0;
      iram_valid = 0;
      instr_access_type = non_access;
      data_access_type = uart_access;
    end else if (dram_d==1 & dram_i==1) begin
      timer_valid = 0;
      uart_valid = 0;
      dram_valid = 1;
      iram_valid = 0;
      instr_access_type = non_access;
      data_access_type = dram_access;
    end else if (iram_d==1 & iram_i==1) begin
      timer_valid = 0;
      uart_valid = 0;
      dram_valid = 0;
      iram_valid = 1;
      instr_access_type = non_access;
      data_access_type = iram_access;
    end else begin
      timer_valid = timer_d | timer_i;
      uart_valid = uart_d | uart_i;
      dram_valid = dram_d | dram_i;
      iram_valid = iram_d | iram_i;
      if (timer_i == 1) begin
        instr_access_type = timer_access;
      end else if (uart_i == 1) begin
        instr_access_type = uart_access;
      end else if (dram_i == 1) begin
        instr_access_type = dram_access;
      end else if (iram_i == 1) begin
        instr_access_type = iram_access;
      end else begin
        instr_access_type = non_access;
      end
      if (timer_d == 1) begin
        data_access_type = timer_access;
      end else if (uart_d == 1) begin
        data_access_type = uart_access;
      end else if (dram_d == 1) begin
        data_access_type = dram_access;
      end else if (iram_d == 1) begin
        data_access_type = iram_access;
      end else begin
        data_access_type = non_access;
      end
    end

    iram_wen = iram_d ? iram_valid & (|dmemory_wstrb) : iram_valid & (|imemory_wstrb);
    iram_instr = iram_d ? dmemory_instr : imemory_instr;
    iram_addr = iram_d ? dmemory_addr ^ iram_base_addr : imemory_addr ^ iram_base_addr;
    iram_wdata = iram_d ? dmemory_wdata : imemory_wdata;
    iram_wstrb = iram_d ? dmemory_wstrb : imemory_wstrb;

    dram_wen = dram_d ? dram_valid & (|dmemory_wstrb) : dram_valid & (|imemory_wstrb);
    dram_instr = dram_d ? dmemory_instr : imemory_instr;
    dram_addr = dram_d ? dmemory_addr ^ dram_base_addr : imemory_addr ^ dram_base_addr;
    dram_wdata = dram_d ? dmemory_wdata : imemory_wdata;
    dram_wstrb = dram_d ? dmemory_wstrb : imemory_wstrb;

    uart_instr = uart_d ? dmemory_instr : imemory_instr;
    uart_addr = uart_d ? dmemory_addr ^ uart_base_addr : imemory_addr ^ uart_base_addr;
    uart_wdata = uart_d ? dmemory_wdata : imemory_wdata;
    uart_wstrb = uart_d ? dmemory_wstrb : imemory_wstrb;

    timer_instr = timer_d ? dmemory_instr : imemory_instr;
    timer_addr = timer_d ? dmemory_addr ^ timer_base_addr : imemory_addr ^ timer_base_addr;
    timer_wdata = timer_d ? dmemory_wdata : imemory_wdata;
    timer_wstrb = timer_d ? dmemory_wstrb : imemory_wstrb;

    if (instr_release_type == iram_access) begin
      imemory_rdata = iram_rdata;
      imemory_ready = iram_ready;
    end else if (instr_release_type == dram_access) begin
      imemory_rdata = dram_rdata;
      imemory_ready = dram_ready;
    end else if  (instr_release_type == uart_access) begin
      imemory_rdata = uart_rdata;
      imemory_ready = uart_ready;
    end else if  (instr_release_type == timer_access) begin
      imemory_rdata = timer_rdata;
      imemory_ready = timer_ready;
    end else begin
      imemory_rdata = 0;
      imemory_ready = 0;
    end

    if (data_release_type == iram_access) begin
      dmemory_rdata = iram_rdata;
      dmemory_ready = iram_ready;
    end else if (data_release_type == dram_access) begin
      dmemory_rdata = dram_rdata;
      dmemory_ready = dram_ready;
    end else if  (data_release_type == uart_access) begin
      dmemory_rdata = uart_rdata;
      dmemory_ready = uart_ready;
    end else if  (data_release_type == timer_access) begin
      dmemory_rdata = timer_rdata;
      dmemory_ready = timer_ready;
    end else begin
      dmemory_rdata = 0;
      dmemory_ready = 0;
    end

  end

  always_ff @(posedge clk_pll) begin
    if (rst == 0) begin
      instr_release_type <= non_access;
      data_release_type <= non_access;
    end else begin
      if (imemory_valid == 1 && (timer_ready | dram_ready | iram_ready) == 1) begin
        instr_release_type <= instr_access_type;
      end
      if (dmemory_valid == 1 && (timer_ready | dram_ready | iram_ready) == 1) begin
        data_release_type <= data_access_type;
      end
    end
  end

  always_ff @(posedge clk_pll) begin

    if (iram_valid == 1) begin
      iram_ready <= 1;
    end else begin
      iram_ready <= 0;
    end

    if (dram_valid == 1) begin
      dram_ready <= 1;
    end else begin
      dram_ready <= 0;
    end

  end

  assign rst_pll = ~rst;

  pll pll_comp
  (
    .refclk (clk),
    .rst (rst_pll),
    .outclk_0 (clk_pll),
    .outclk_1 (rtc),
    .locked (locked)
  );

  cpu cpu_comp
  (
    .rst (locked),
    .clk (clk_pll),
    .imemory_valid (imemory_valid),
    .imemory_instr (imemory_instr),
    .imemory_addr (imemory_addr),
    .imemory_wdata (imemory_wdata),
    .imemory_wstrb (imemory_wstrb),
    .imemory_rdata (imemory_rdata),
    .imemory_ready (imemory_ready),
    .dmemory_valid (dmemory_valid),
    .dmemory_instr (dmemory_instr),
    .dmemory_addr (dmemory_addr),
    .dmemory_wdata (dmemory_wdata),
    .dmemory_wstrb (dmemory_wstrb),
    .dmemory_rdata (dmemory_rdata),
    .dmemory_ready (dmemory_ready),
    .extern_irpt (1'b0),
    .timer_irpt (timer_irpt),
    .soft_irpt (1'b0)
  );

  iram iram_comp
  (
    .clk (clk_pll),
    .iram_wen (iram_wen),
    .iram_waddr (iram_addr),
    .iram_raddr (iram_addr),
    .iram_wdata (iram_wdata),
    .iram_wstrb (iram_wstrb),
    .iram_rdata (iram_rdata)
  );

  dram dram_comp
  (
    .clk (clk_pll),
    .dram_wen (dram_wen),
    .dram_waddr (dram_addr),
    .dram_raddr (dram_addr),
    .dram_wdata (dram_wdata),
    .dram_wstrb (dram_wstrb),
    .dram_rdata (dram_rdata)
  );

  uart uart_comp
  (
    .rst (locked),
    .clk (clk_pll),
    .uart_valid (uart_valid),
    .uart_instr (uart_instr),
    .uart_addr (uart_addr),
    .uart_wdata (uart_wdata),
    .uart_wstrb (uart_wstrb),
    .uart_rdata (uart_rdata),
    .uart_ready (uart_ready),
    .uart_rx (rx),
    .uart_tx (tx)
  );

  timer timer_comp
  (
    .rst (locked),
    .clk (clk_pll),
    .rtc (rtc),
    .timer_valid (timer_valid),
    .timer_instr (timer_instr),
    .timer_addr (timer_addr),
    .timer_wdata (timer_wdata),
    .timer_wstrb (timer_wstrb),
    .timer_rdata (timer_rdata),
    .timer_ready (timer_ready),
    .timer_irpt (timer_irpt)
  );

endmodule
