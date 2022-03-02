module soc
(
  input logic rst,
  input logic clk,
  input logic rtc
);
  timeunit 1ns;
  timeprecision 1ps;

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

  logic [0  : 0] bram_valid;
  logic [0  : 0] bram_instr;
  logic [31 : 0] bram_addr;
  logic [31 : 0] bram_wdata;
  logic [3  : 0] bram_wstrb;
  logic [31 : 0] bram_rdata;
  logic [0  : 0] bram_ready;

  logic [0  : 0] print_valid;
  logic [0  : 0] print_instr;
  logic [31 : 0] print_addr;
  logic [31 : 0] print_wdata;
  logic [3  : 0] print_wstrb;
  logic [31 : 0] print_rdata;
  logic [0  : 0] print_ready;

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

  logic [0  : 0] bram_i;
  logic [0  : 0] bram_d;
  logic [0  : 0] print_i;
  logic [0  : 0] print_d;
  logic [0  : 0] clint_i;
  logic [0  : 0] clint_d;

  parameter [1  : 0] bram_access = 0;
  parameter [1  : 0] print_access = 1;
  parameter [1  : 0] clint_access = 2;
  parameter [1  : 0] non_access = 3;

  logic [1  : 0] instr_access_type;
  logic [1  : 0] instr_release_type;

  logic [1  : 0] data_access_type;
  logic [1  : 0] data_release_type;

  always_comb begin

    if (dmemory_addr >= clint_base_addr &&
      dmemory_addr < clint_top_addr) begin
        clint_d = dmemory_valid;
        print_d = 0;
        bram_d = 0;
    end else if (dmemory_addr >= print_base_addr &&
      dmemory_addr < print_top_addr) begin
        clint_d = 0;
        print_d = dmemory_valid;
        bram_d = 0;
    end else if (dmemory_addr >= bram_base_addr &&
      dmemory_addr < bram_top_addr) begin
        clint_d = 0;
        print_d = 0;
        bram_d = dmemory_valid;
    end else begin
      clint_d = 0;
      print_d = 0;
      bram_d = 0;
    end

    if (imemory_addr >= clint_base_addr &&
      imemory_addr < clint_top_addr) begin
        clint_i = imemory_valid;
        print_i = 0;
        bram_i = 0;
    end else if (imemory_addr >= print_base_addr &&
      imemory_addr < print_top_addr) begin
        clint_i = 0;
        print_i = imemory_valid;
        bram_i = 0;
    end else if (imemory_addr >= bram_base_addr &&
      imemory_addr < bram_top_addr) begin
        clint_i = 0;
        print_i = 0;
        bram_i = imemory_valid;
    end else begin
      clint_i = 0;
      print_i = 0;
      bram_i = 0;
    end

    if (clint_d==1 & clint_i==1) begin
      clint_valid = 1;
      print_valid = 0;
      bram_valid = 0;
      instr_access_type = non_access;
      data_access_type = clint_access;
    end else if (print_d==1 & print_i==1) begin
      clint_valid = 0;
      print_valid = 1;
      bram_valid = 0;
      instr_access_type = non_access;
      data_access_type = print_access;
    end else if (bram_d==1 & bram_i==1) begin
      clint_valid = 0;
      print_valid = 0;
      bram_valid = 1;
      instr_access_type = non_access;
      data_access_type = bram_access;
    end else begin
      clint_valid = clint_d | clint_i;
      print_valid = print_d | print_i;
      bram_valid = bram_d | bram_i;
      if (clint_i == 1) begin
        instr_access_type = clint_access;
      end else if (print_i == 1) begin
        instr_access_type = print_access;
      end else if (bram_i == 1) begin
        instr_access_type = bram_access;
      end else begin
        instr_access_type = non_access;
      end
      if (clint_d == 1) begin
        data_access_type = clint_access;
      end else if (print_d == 1) begin
        data_access_type = print_access;
      end else if (bram_d == 1) begin
        data_access_type = bram_access;
      end else begin
        data_access_type = non_access;
      end
    end

    bram_instr = bram_d ? dmemory_instr : imemory_instr;
    bram_addr = bram_d ? dmemory_addr ^ bram_base_addr : imemory_addr ^ bram_base_addr;
    bram_wdata = bram_d ? dmemory_wdata : imemory_wdata;
    bram_wstrb = bram_d ? dmemory_wstrb : imemory_wstrb;

    print_instr = print_d ? dmemory_instr : imemory_instr;
    print_addr = print_d ? dmemory_addr ^ print_base_addr : imemory_addr ^ print_base_addr;
    print_wdata = print_d ? dmemory_wdata : imemory_wdata;
    print_wstrb = print_d ? dmemory_wstrb : imemory_wstrb;

    clint_instr = clint_d ? dmemory_instr : imemory_instr;
    clint_addr = clint_d ? dmemory_addr ^ clint_base_addr : imemory_addr ^ clint_base_addr;
    clint_wdata = clint_d ? dmemory_wdata : imemory_wdata;
    clint_wstrb = clint_d ? dmemory_wstrb : imemory_wstrb;

    if (instr_release_type == bram_access) begin
      imemory_rdata = bram_rdata;
      imemory_ready = bram_ready;
    end else if  (instr_release_type == print_access) begin
      imemory_rdata = print_rdata;
      imemory_ready = print_ready;
    end else if  (instr_release_type == clint_access) begin
      imemory_rdata = clint_rdata;
      imemory_ready = clint_ready;
    end else begin
      imemory_rdata = 0;
      imemory_ready = 0;
    end

    if (data_release_type == bram_access) begin
      dmemory_rdata = bram_rdata;
      dmemory_ready = bram_ready;
    end else if  (data_release_type == print_access) begin
      dmemory_rdata = print_rdata;
      dmemory_ready = print_ready;
    end else if  (data_release_type == clint_access) begin
      dmemory_rdata = clint_rdata;
      dmemory_ready = clint_ready;
    end else begin
      dmemory_rdata = 0;
      dmemory_ready = 0;
    end

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      instr_release_type <= non_access;
      data_release_type <= non_access;
    end else begin
      if (imemory_valid == 1 && (clint_ready | bram_ready | print_ready) == 1) begin
        instr_release_type <= instr_access_type;
      end
      if (dmemory_valid == 1 && (clint_ready | bram_ready | print_ready) == 1) begin
        data_release_type <= data_access_type;
      end
    end
  end

  cpu cpu_comp
  (
    .rst (rst),
    .clk (clk),
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

  bram bram_comp
  (
    .rst (rst),
    .clk (clk),
    .bram_valid (bram_valid),
    .bram_instr (bram_instr),
    .bram_addr (bram_addr),
    .bram_wdata (bram_wdata),
    .bram_wstrb (bram_wstrb),
    .bram_rdata (bram_rdata),
    .bram_ready (bram_ready)
  );

  check check_comp
  (
    .rst (rst),
    .clk (clk),
    .check_valid (bram_valid),
    .check_instr (bram_instr),
    .check_addr (bram_addr),
    .check_wdata (bram_wdata),
    .check_wstrb (bram_wstrb)
  );

  print print_comp
  (
    .rst (rst),
    .clk (clk),
    .print_valid (print_valid),
    .print_instr (print_instr),
    .print_addr (print_addr),
    .print_wdata (print_wdata),
    .print_wstrb (print_wstrb),
    .print_rdata (print_rdata),
    .print_ready (print_ready)
  );

  clint clint_comp
  (
    .rst (rst),
    .clk (clk),
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
