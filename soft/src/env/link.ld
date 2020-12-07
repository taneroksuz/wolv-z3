OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
  iram : ORIGIN = 0x00000, LENGTH = 128K
  dram : ORIGIN = 0x20000, LENGTH = 128K
}

SECTIONS
{
  .text.init : {
    . = 0x0;
    *(.text.init)
  } > iram
  .tohost : {
    . = ALIGN(0x1000);
    *(.tohost)
  } > iram
  .text : {
    . = ALIGN(0x1000);
    *(.text)
  } > iram
  .data : {
    . = ALIGN(0x1000);
    *(.data)
  } > dram
  .bss : {
    *(.bss)
    _end = .;
  } > dram
}
