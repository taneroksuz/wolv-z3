OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
  iram : ORIGIN = 0x00000, LENGTH = 128K
  dram : ORIGIN = 0x20000, LENGTH = 128K
}

SECTIONS
{
  .text : {
    . = 0x0;
    *(.text)
  } > iram
  .data : { *(.data) } > dram
  .bss : {
    *(.bss)
    _end = .;
  } > dram
}
