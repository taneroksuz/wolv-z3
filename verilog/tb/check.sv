import configure::*;

module check
(
  input logic rst,
  input logic clk,
  input logic [0   : 0] check_valid,
  input logic [0   : 0] check_instr,
  input logic [31  : 0] check_addr,
  input logic [31  : 0] check_wdata,
  input logic [3   : 0] check_wstrb
);
	timeunit 1ns;
	timeprecision 1ps;

  logic [31 : 0] host[0:0];
  logic [31 : 0] begin_signature[0:0];
  logic [31 : 0] end_signature[0:0];

  task check;
    input logic [31 : 0] check_addr;
    input logic [31 : 0] check_wdata;
    input logic [3  : 0] check_wstrb;
    input logic [31 : 0] host;
    logic [0 : 0] ok;
    begin
      ok = 0;
      if (check_addr[31:2] == host[31:2] && |check_wstrb == 1) begin
        ok = 1;
      end
      if (ok == 1) begin
        if (check_wdata == 32'h1) begin
          $display("TEST SUCCEEDED");
          $finish;
        end else begin
          $display("TEST FAILED");
          $finish;
        end
      end
    end
  endtask

  task signature;
    input logic [31 : 0] check_addr;
    input logic [31 : 0] check_wdata;
    input logic [3  : 0] check_wstrb;
    input logic [31 : 0] begin_signature;
    input logic [31 : 0] end_signature;
    begin
      if (check_addr[31:2] >= begin_signature[31:2] && check_addr[31:2] <= end_signature[31:2] && |check_wstrb == 1) begin
        $write("%H",check_wdata);
      end
    end
  endtask

  initial begin
    $readmemh("host.dat", host);
    $readmemh("begin_signature.dat", begin_signature);
    $readmemh("end_signature.dat", end_signature);
  end

  always_ff @(posedge clk) begin

    if (check_valid == 1) begin

      check(check_addr,check_wdata,check_wstrb,host[0]);

      signature(check_addr,check_wdata,check_wstrb,begin_signature[0],end_signature[0]);

    end

  end


endmodule
