import configure::*;

module top_cpu
(
  input logic rst,
  input logic clk,
  input logic rx,
  output logic tx
);
  timeunit 1ns;
  timeprecision 1ps;

  logic rtc;
  logic [31 : 0] count;

  logic clk_pll;
  logic [31 : 0] count_pll;

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
  logic [0  : 0] iram_instr;
  logic [31 : 0] iram_addr;
  logic [31 : 0] iram_wdata;
  logic [3  : 0] iram_wstrb;
  logic [31 : 0] iram_rdata;
  logic [0  : 0] iram_ready;

  logic [0  : 0] dram_valid;
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

  always_ff @(posedge clk) begin

    if (rst == 0) begin
      rtc <= 0;
      count <= 0;
      clk_pll <= 0;
      count_pll <= 0;
    end else begin
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
  end

  always_comb begin

    case(imemory_addr) inside
      [uart_base_addr:uart_top_addr-1]:
        begin
          uart_valid = imemory_valid;
          timer_valid = 0;
          dram_valid = 0;
          iram_valid = 0;
        end
      [timer_base_addr:timer_top_addr-1]:
        begin
          uart_valid = 0;
          timer_valid = imemory_valid;
          dram_valid = 0;
          iram_valid = 0;
        end
      [dram_base_addr:dram_top_addr-1]:
        begin
          uart_valid = 0;
          timer_valid = 0;
          dram_valid = imemory_valid;
          iram_valid = 0;
        end
      [iram_base_addr:iram_top_addr-1]:
        begin
          uart_valid = 0;
          timer_valid = 0;
          dram_valid = 0;
          iram_valid = imemory_valid;
        end
      default:
        begin
          uart_valid = 0;
          timer_valid = 0;
          dram_valid = 0;
          iram_valid = 0;
        end
    endcase

    case(dmemory_addr) inside
      [uart_base_addr:uart_top_addr-1]:
        begin
          uart_valid = dmemory_valid;
          timer_valid = 0;
          dram_valid = 0;
          iram_valid = 0;
        end
      [timer_base_addr:timer_top_addr-1]:
        begin
          uart_valid = 0;
          timer_valid = dmemory_valid;
          dram_valid = 0;
          iram_valid = 0;
        end
      [dram_base_addr:dram_top_addr-1]:
        begin
          uart_valid = 0;
          timer_valid = 0;
          dram_valid = dmemory_valid;
          iram_valid = 0;
        end
      [iram_base_addr:iram_top_addr-1]:
        begin
          uart_valid = 0;
          timer_valid = 0;
          dram_valid = 0;
          iram_valid = dmemory_valid;
        end
      default:
        begin
          uart_valid = 0;
          timer_valid = 0;
          dram_valid = 0;
          iram_valid = 0;
        end
    endcase

    iram_instr = dmemory_valid ? dmemory_instr : imemory_instr;
    iram_addr = dmemory_valid ? dmemory_addr ^ iram_base_addr : imemory_addr ^ iram_base_addr;
    iram_wdata = dmemory_valid ? dmemory_wdata : imemory_wdata;
    iram_wstrb = dmemory_valid ? dmemory_wstrb : imemory_wstrb;

    dram_instr = dmemory_valid ? dmemory_instr : imemory_instr;
    dram_addr = dmemory_valid ? dmemory_addr ^ dram_base_addr : imemory_addr ^ dram_base_addr;
    dram_wdata = dmemory_valid ? dmemory_wdata : imemory_wdata;
    dram_wstrb = dmemory_valid ? dmemory_wstrb : imemory_wstrb;

    timer_instr = dmemory_valid ? dmemory_instr : imemory_instr;
    timer_addr = dmemory_valid ? dmemory_addr ^ timer_base_addr : imemory_addr ^ timer_base_addr;
    timer_wdata = dmemory_valid ? dmemory_wdata : imemory_wdata;
    timer_wstrb = dmemory_valid ? dmemory_wstrb : imemory_wstrb;

    uart_instr = dmemory_valid ? dmemory_instr : imemory_instr;
    uart_addr = dmemory_valid ? dmemory_addr ^ timer_base_addr : imemory_addr ^ timer_base_addr;
    uart_wdata = dmemory_valid ? dmemory_wdata : imemory_wdata;
    uart_wstrb = dmemory_valid ? dmemory_wstrb : imemory_wstrb;

    if (iram_ready == 1) begin
      imemory_rdata = iram_rdata;
      imemory_ready = iram_ready;
    end else if (dram_ready == 1) begin
      imemory_rdata = dram_rdata;
      imemory_ready = dram_ready;
    end else if  (timer_ready == 1) begin
      imemory_rdata = timer_rdata;
      imemory_ready = timer_ready;
    end else if  (uart_ready == 1) begin
      imemory_rdata = uart_rdata;
      imemory_ready = uart_ready;
    end else begin
      imemory_rdata = 0;
      imemory_ready = 0;
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
    .extern_irpt (1'b0),
    .timer_irpt (timer_irpt),
    .soft_irpt (1'b0)
  );

  iram iram_comp
  (
    .rst (rst),
    .clk (clk),
    .iram_valid (iram_valid),
    .iram_instr (iram_instr),
    .iram_addr (iram_addr),
    .iram_wdata (iram_wdata),
    .iram_wstrb (iram_wstrb),
    .iram_rdata (iram_rdata),
    .iram_ready (iram_ready)
  );

  dram dram_comp
  (
    .rst (rst),
    .clk (clk),
    .dram_valid (dram_valid),
    .dram_instr (dram_instr),
    .dram_addr (dram_addr),
    .dram_wdata (dram_wdata),
    .dram_wstrb (dram_wstrb),
    .dram_rdata (dram_rdata),
    .dram_ready (dram_ready)
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

  timer timer_comp
  (
    .rst (rst),
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
