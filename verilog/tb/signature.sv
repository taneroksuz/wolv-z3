import configure::*;

module signature
(
  input logic rst,
  input logic clk,
  input mem_in_type dmem_in
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31 : 0] sig_b[0:0] = '{default:'0};
  logic [31 : 0] sig_e[0:0] = '{default:'0};

  int sig_beg;
  int sig_end;
  int sig;

  task signature;
    input logic [31 : 0] addr;
    input logic [31 : 0] wdata;
    input logic [3  : 0] wstrb;
    input logic [31 : 0] sig_b;
    input logic [31 : 0] sig_e;
    input int sig;
    begin
      if (addr[31:2] >= sig_b[31:2] && addr[31:2] <= sig_e[31:2] && |wstrb == 1) begin
        $fwrite(sig,"%H\n",wdata);
      end
    end
  endtask

  initial begin
    sig_beg = $fopen("begin_signature.dat","r");
    sig_end = $fopen("end_signature.dat","r");
    sig = $fopen("signature.dat","w");
    if (sig_beg != 0) begin
      $readmemh("begin_signature.dat", sig_b);
    end
    if (sig_end != 0) begin
      $readmemh("end_signature.dat", sig_e);
    end
  end

  always_ff @(posedge clk) begin

    if (dmem_in.mem_valid == 1) begin

      signature(dmem_in.mem_addr,dmem_in.mem_wdata,dmem_in.mem_wstrb,sig_b[0],sig_e[0],sig);

    end

  end

endmodule
