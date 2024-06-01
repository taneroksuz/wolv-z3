import configure::*;

module soc();

  timeunit 1ns;
  timeprecision 1ps;

  logic reset;
  logic clock;

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

  logic [0  : 0] memory_valid;
  logic [0  : 0] memory_instr;
  logic [31 : 0] memory_addr;
  logic [31 : 0] memory_wdata;
  logic [3  : 0] memory_wstrb;
  logic [31 : 0] memory_rdata;
  logic [0  : 0] memory_ready;

  logic [0  : 0] rom_valid;
  logic [0  : 0] rom_instr;
  logic [31 : 0] rom_addr;
  logic [31 : 0] rom_rdata;
  logic [0  : 0] rom_ready;

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

  logic [0  : 0] itim_valid;
  logic [0  : 0] itim_instr;
  logic [31 : 0] itim_addr;
  logic [31 : 0] itim_wdata;
  logic [3  : 0] itim_wstrb;
  logic [31 : 0] itim_rdata;
  logic [0  : 0] itim_ready;

  logic [0  : 0] dtim_valid;
  logic [0  : 0] dtim_instr;
  logic [31 : 0] dtim_addr;
  logic [31 : 0] dtim_wdata;
  logic [3  : 0] dtim_wstrb;
  logic [31 : 0] dtim_rdata;
  logic [0  : 0] dtim_ready;

  logic [0  : 0] ram_valid;
  logic [0  : 0] ram_instr;
  logic [31 : 0] ram_addr;
  logic [31 : 0] ram_wdata;
  logic [3  : 0] ram_wstrb;
  logic [31 : 0] ram_rdata;
  logic [0  : 0] ram_ready;

  logic [0  : 0] meip;
  logic [0  : 0] msip;
  logic [0  : 0] mtip;

  logic [63 : 0] mtime;

  logic [31 : 0] mem_addr;

  logic [31 : 0] base_addr;

  logic [31 : 0] host[0:0] = '{default:'0};

  logic [31 : 0] stoptime = 1000;
  logic [31 : 0] counter = 0;

  integer reg_file;
  integer csr_file;
  integer mem_file;

  initial begin
    $readmemh("host.dat", host);
  end

  initial begin
    string filename;
    if ($value$plusargs("FILENAME=%s",filename)) begin
      $dumpfile(filename);
      $dumpvars(0, soc);
    end
  end

  initial begin
    string maxtime;
    if ($value$plusargs("MAXTIME=%s",maxtime)) begin
      stoptime = maxtime.atoi();
    end
  end

  initial begin
    reset = 0;
    clock = 1;
  end

  initial begin
    #10 reset = 1;
  end

  always #0.5 clock = ~clock;

  initial begin
    string filename;
    if ($value$plusargs("REGFILE=%s",filename)) begin
      reg_file = $fopen(filename,"w");
      for (int i=0; i<stoptime; i=i+1) begin
        @(posedge clock);
        if (soc.cpu_comp.register_comp.register_win.wren == 1) begin
          $fwrite(reg_file,"PERIOD = %t\t",$time);
          $fwrite(reg_file,"PC = %x\t",soc.cpu_comp.execute_stage_comp.a.e.instr.pc);
          $fwrite(reg_file,"WADDR = %d\t",soc.cpu_comp.register_comp.register_win.waddr);
          $fwrite(reg_file,"WDATA = %x\n",soc.cpu_comp.register_comp.register_win.wdata);
        end
      end
      $fclose(reg_file);
    end
  end

  initial begin
    string filename;
    if ($value$plusargs("CSRFILE=%s",filename)) begin
      csr_file = $fopen(filename,"w");
      for (int i=0; i<stoptime; i=i+1) begin
        @(posedge clock);
        if (soc.cpu_comp.csr_comp.csr_ein.cwren == 1) begin
          $fwrite(csr_file,"PERIOD = %t\t",$time);
          $fwrite(csr_file,"PC = %x\t",soc.cpu_comp.execute_stage_comp.a.e.instr.pc);
          $fwrite(csr_file,"WADDR = %x\t",soc.cpu_comp.csr_comp.csr_ein.cwaddr);
          $fwrite(csr_file,"WDATA = %x\n",soc.cpu_comp.csr_comp.csr_ein.cdata);
        end
      end
      $fclose(csr_file);
    end
  end

  initial begin
    string filename;
    if ($value$plusargs("MEMFILE=%s",filename)) begin
      mem_file = $fopen(filename,"w");
      for (int i=0; i<stoptime; i=i+1) begin
        @(posedge clock);
        if (soc.cpu_comp.decode_stage_comp.dmem_in.mem_valid == 1) begin
          if (|soc.cpu_comp.decode_stage_comp.dmem_in.mem_wstrb == 1) begin
            $fwrite(mem_file,"PERIOD = %t\t",$time);
            $fwrite(mem_file,"PC = %x\t",soc.cpu_comp.execute_stage_comp.a.e.instr.pc);
            $fwrite(mem_file,"WADDR = %x\t",soc.cpu_comp.decode_stage_comp.dmem_in.mem_addr);
            $fwrite(mem_file,"WSTRB = %b\t",soc.cpu_comp.decode_stage_comp.dmem_in.mem_wstrb);
            $fwrite(mem_file,"WDATA = %x\n",soc.cpu_comp.decode_stage_comp.dmem_in.mem_wdata);
          end
        end
      end
      $fclose(mem_file);
    end
  end

  always_ff @(posedge clock) begin
    if (counter == stoptime) begin
      $finish;
    end else begin
      counter <= counter + 1;
    end
  end

  always_ff @(posedge clock) begin
    if (soc.cpu_comp.decode_stage_comp.dmem_in.mem_valid == 1) begin
      if (soc.cpu_comp.decode_stage_comp.dmem_in.mem_addr[31:2] == host[0][31:2]) begin
        if (|soc.cpu_comp.decode_stage_comp.dmem_in.mem_wstrb == 1) begin
          if (|soc.cpu_comp.decode_stage_comp.dmem_in.mem_wdata == 1) begin
            $finish;
          end
        end
      end
    end
  end

  always_comb begin

    rom_valid = 0;
    print_valid = 0;
    clint_valid = 0;
    itim_valid = 0;
    dtim_valid = 0;
    ram_valid = 0;

    base_addr = 0;

    if (memory_valid == 1) begin
      if (memory_addr >= ram_base_addr && memory_addr < ram_top_addr) begin
          ram_valid = memory_valid;
          base_addr = ram_base_addr;
      end else if (memory_addr >= dtim_base_addr && memory_addr < dtim_top_addr) begin
          dtim_valid = memory_valid;
          base_addr = dtim_base_addr;
      end else if (memory_addr >= itim_base_addr && memory_addr < itim_top_addr) begin
          itim_valid = memory_valid;
          base_addr = itim_base_addr;
      end else if (memory_addr >= clint_base_addr && memory_addr < clint_top_addr) begin
          clint_valid = memory_valid;
          base_addr = clint_base_addr;
      end else if (memory_addr >= print_base_addr && memory_addr < print_top_addr) begin
          print_valid = memory_valid;
          base_addr = print_base_addr;
      end else if (memory_addr >= rom_base_addr && memory_addr < rom_top_addr) begin
          rom_valid = memory_valid;
          base_addr = rom_base_addr;
      end
    end

    mem_addr = memory_addr - base_addr;

    rom_instr = memory_instr;
    rom_addr = mem_addr;

    print_instr = memory_instr;
    print_addr = mem_addr;
    print_wdata = memory_wdata;
    print_wstrb = memory_wstrb;

    clint_instr = memory_instr;
    clint_addr = mem_addr;
    clint_wdata = memory_wdata;
    clint_wstrb = memory_wstrb;

    itim_instr = memory_instr;
    itim_addr = mem_addr;
    itim_wdata = memory_wdata;
    itim_wstrb = memory_wstrb;

    dtim_instr = memory_instr;
    dtim_addr = mem_addr;
    dtim_wdata = memory_wdata;
    dtim_wstrb = memory_wstrb;

    ram_instr = memory_instr;
    ram_addr = mem_addr;
    ram_wdata = memory_wdata;
    ram_wstrb = memory_wstrb;

    if (rom_ready == 1) begin
      memory_rdata = rom_rdata;
      memory_ready = rom_ready;
    end else if  (print_ready == 1) begin
      memory_rdata = print_rdata;
      memory_ready = print_ready;
    end else if  (clint_ready == 1) begin
      memory_rdata = clint_rdata;
      memory_ready = clint_ready;
    end else if (itim_ready == 1) begin
      memory_rdata = itim_rdata;
      memory_ready = itim_ready;
    end else if (dtim_ready == 1) begin
      memory_rdata = dtim_rdata;
      memory_ready = dtim_ready;
    end else if (ram_ready == 1) begin
      memory_rdata = ram_rdata;
      memory_ready = ram_ready;
    end else begin
      memory_rdata = 0;
      memory_ready = 0;
    end

  end

  cpu cpu_comp
  (
    .reset (reset),
    .clock (clock),
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
    .meip (meip),
    .msip (msip),
    .mtip (mtip),
    .mtime (mtime)
  );

  arbiter arbiter_comp
  (
    .reset (reset),
    .clock (clock),
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
    .memory_valid (memory_valid),
    .memory_instr (memory_instr),
    .memory_addr (memory_addr),
    .memory_wdata (memory_wdata),
    .memory_wstrb (memory_wstrb),
    .memory_rdata (memory_rdata),
    .memory_ready (memory_ready)
  );

  rom rom_comp
  (
    .reset (reset),
    .clock (clock),
    .rom_valid (rom_valid),
    .rom_instr (rom_instr),
    .rom_addr (rom_addr),
    .rom_rdata (rom_rdata),
    .rom_ready (rom_ready)
  );

  print print_comp
  (
    .reset (reset),
    .clock (clock),
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
    .reset (reset),
    .clock (clock),
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

  tim itim_comp
  (
    .reset (reset),
    .clock (clock),
    .tim_valid (itim_valid),
    .tim_instr (itim_instr),
    .tim_addr (itim_addr),
    .tim_wdata (itim_wdata),
    .tim_wstrb (itim_wstrb),
    .tim_rdata (itim_rdata),
    .tim_ready (itim_ready)
  );

  tim dtim_comp
  (
    .reset (reset),
    .clock (clock),
    .tim_valid (dtim_valid),
    .tim_instr (dtim_instr),
    .tim_addr (dtim_addr),
    .tim_wdata (dtim_wdata),
    .tim_wstrb (dtim_wstrb),
    .tim_rdata (dtim_rdata),
    .tim_ready (dtim_ready)
  );

  ram ram_comp
  (
    .reset (reset),
    .clock (clock),
    .ram_valid (ram_valid),
    .ram_instr (ram_instr),
    .ram_addr (ram_addr),
    .ram_wdata (ram_wdata),
    .ram_wstrb (ram_wstrb),
    .ram_rdata (ram_rdata),
    .ram_ready (ram_ready)
  );

endmodule
