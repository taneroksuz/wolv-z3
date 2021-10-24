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

  logic rtc = 0;
  logic [31 : 0] count = 0;

  logic clk_pll = 0;
  logic [31 : 0] count_pll = 0;

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

  logic [0  : 0] clint_valid;
  logic [0  : 0] clint_instr;
  logic [31 : 0] clint_addr;
  logic [31 : 0] clint_wdata;
  logic [3  : 0] clint_wstrb;
  logic [31 : 0] clint_rdata;
  logic [0  : 0] clint_ready;

  logic [2**plic_contexts-1 : 0] meip;
  logic [2**clint_contexts-1 : 0] msip;
  logic [2**clint_contexts-1 : 0] mtip;

  logic [63 : 0] mtime;

  logic [0  : 0] iram_i;
  logic [0  : 0] iram_d;
  logic [0  : 0] dram_i;
  logic [0  : 0] dram_d;
  logic [0  : 0] uart_i;
  logic [0  : 0] uart_d;
  logic [0  : 0] clint_i;
  logic [0  : 0] clint_d;

  parameter [2  : 0] iram_access = 0;
  parameter [2  : 0] dram_access = 1;
  parameter [2  : 0] uart_access = 2;
  parameter [2  : 0] clint_access = 3;
  parameter [2  : 0] non_access = 4;

  logic [2  : 0] instr_access_type;
  logic [2  : 0] instr_release_type;

  logic [2  : 0] data_access_type;
  logic [2  : 0] data_release_type;

  always_ff @(posedge clk) begin
    if (count == clk_divider_rtc) begin
      rtc <= ~rtc;
      count <= 0;
    end else begin
      count <= count + 1;
    end
    if (count_pll == clk_divider_pll) begin
      clk_pll <= ~clk_pll;
      count_pll <= 0;
    end else begin
      count_pll <= count_pll + 1;
    end
  end

  always_comb begin

    if (dmemory_addr >= clint_base_addr &&
      dmemory_addr < clint_top_addr) begin
        clint_d = dmemory_valid;
        uart_d = 0;
        dram_d = 0;
        iram_d = 0;
    end else if (dmemory_addr >= uart_base_addr &&
      dmemory_addr < uart_top_addr) begin
        clint_d = 0;
        uart_d = dmemory_valid;
        dram_d = 0;
        iram_d = 0;
    end else if (dmemory_addr >= dram_base_addr &&
      dmemory_addr < dram_top_addr) begin
        clint_d = 0;
        uart_d = 0;
        dram_d = dmemory_valid;
        iram_d = 0;
    end else if (dmemory_addr >= iram_base_addr &&
      dmemory_addr < iram_top_addr) begin
        clint_d = 0;
        uart_d = 0;
        dram_d = 0;
        iram_d = dmemory_valid;
    end else begin
      clint_d = 0;
      uart_d = 0;
      dram_d = 0;
      iram_d = 0;
    end

    if (imemory_addr >= clint_base_addr &&
      imemory_addr < clint_top_addr) begin
        clint_i = imemory_valid;
        uart_i = 0;
        dram_i = 0;
        iram_i = 0;
    end else if (imemory_addr >= uart_base_addr &&
      imemory_addr < uart_top_addr) begin
        clint_i = 0;
        uart_i = imemory_valid;
        dram_i = 0;
        iram_i = 0;
    end else if (imemory_addr >= dram_base_addr &&
      imemory_addr < dram_top_addr) begin
        clint_i = 0;
        uart_i = 0;
        dram_i = imemory_valid;
        iram_i = 0;
    end else if (imemory_addr >= iram_base_addr &&
      imemory_addr < iram_top_addr) begin
        clint_i = 0;
        uart_i = 0;
        dram_i = 0;
        iram_i = imemory_valid;
    end else begin
      clint_i = 0;
      uart_i = 0;
      dram_i = 0;
      iram_i = 0;
    end

    if (clint_d==1 & clint_i==1) begin
      clint_valid = 1;
      uart_valid = 0;
      dram_valid = 0;
      iram_valid = 0;
      instr_access_type = non_access;
      data_access_type = clint_access;
    end else if (uart_d==1 & uart_i==1) begin
      clint_valid = 0;
      uart_valid = 1;
      dram_valid = 0;
      iram_valid = 0;
      instr_access_type = non_access;
      data_access_type = uart_access;
    end else if (dram_d==1 & dram_i==1) begin
      clint_valid = 0;
      uart_valid = 0;
      dram_valid = 1;
      iram_valid = 0;
      instr_access_type = non_access;
      data_access_type = dram_access;
    end else if (iram_d==1 & iram_i==1) begin
      clint_valid = 0;
      uart_valid = 0;
      dram_valid = 0;
      iram_valid = 1;
      instr_access_type = non_access;
      data_access_type = iram_access;
    end else begin
      clint_valid = clint_d | clint_i;
      uart_valid = uart_d | uart_i;
      dram_valid = dram_d | dram_i;
      iram_valid = iram_d | iram_i;
      if (clint_i == 1) begin
        instr_access_type = clint_access;
      end else if (uart_i == 1) begin
        instr_access_type = uart_access;
      end else if (dram_i == 1) begin
        instr_access_type = dram_access;
      end else if (iram_i == 1) begin
        instr_access_type = iram_access;
      end else begin
        instr_access_type = non_access;
      end
      if (clint_d == 1) begin
        data_access_type = clint_access;
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

    clint_instr = clint_d ? dmemory_instr : imemory_instr;
    clint_addr = clint_d ? dmemory_addr ^ clint_base_addr : imemory_addr ^ clint_base_addr;
    clint_wdata = clint_d ? dmemory_wdata : imemory_wdata;
    clint_wstrb = clint_d ? dmemory_wstrb : imemory_wstrb;

    if (instr_release_type == iram_access) begin
      imemory_rdata = iram_rdata;
      imemory_ready = iram_ready;
    end else if (instr_release_type == dram_access) begin
      imemory_rdata = dram_rdata;
      imemory_ready = dram_ready;
    end else if  (instr_release_type == uart_access) begin
      imemory_rdata = uart_rdata;
      imemory_ready = uart_ready;
    end else if  (instr_release_type == clint_access) begin
      imemory_rdata = clint_rdata;
      imemory_ready = clint_ready;
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
    end else if  (data_release_type == clint_access) begin
      dmemory_rdata = clint_rdata;
      dmemory_ready = clint_ready;
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
      if (imemory_valid == 1 && (clint_ready | dram_ready | iram_ready) == 1) begin
        instr_release_type <= instr_access_type;
      end
      if (dmemory_valid == 1 && (clint_ready | dram_ready | iram_ready) == 1) begin
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

  cpu cpu_comp
  (
    .rst (rst),
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
    .meip (meip[0]),
    .msip (msip[0]),
    .mtip (mtip[0]),
    .mtime (mtime)
  );

  iram iram_comp
  (
    .clk (clk_pll),
    .iram_wen (iram_wen),
    .iram_waddr (iram_addr[iram_depth+1:2]),
    .iram_raddr (iram_addr[iram_depth+1:2]),
    .iram_wdata (iram_wdata),
    .iram_wstrb (iram_wstrb),
    .iram_rdata (iram_rdata)
  );

  dram dram_comp
  (
    .clk (clk_pll),
    .dram_wen (dram_wen),
    .dram_waddr (dram_addr[dram_depth+1:2]),
    .dram_raddr (dram_addr[dram_depth+1:2]),
    .dram_wdata (dram_wdata),
    .dram_wstrb (dram_wstrb),
    .dram_rdata (dram_rdata)
  );

  uart uart_comp
  (
    .rst (rst),
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

  clint clint_comp
  (
    .rst (rst),
    .clk (clk_pll),
    .rtc (rtc),
    .clint_valid (clint_valid),
    .clint_instr (clint_instr),
    .clint_addr (clint_addr),
    .clint_wdata (clint_wdata),
    .clint_wstrb (clint_wstrb),
    .clint_rdata (clint_rdata),
    .clint_ready (clint_ready),
    .clint_msip (msip),
    .clint_mtip (mtip),
    .clint_mtime (mtime)
  );

endmodule
