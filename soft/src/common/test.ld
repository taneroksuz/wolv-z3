/*======================================================================*/
/* Proxy kernel linker script                                           */
/*======================================================================*/
/* This is the linker script used when building the proxy kernel. */

/*----------------------------------------------------------------------*/
/* Setup                                                                */
/*----------------------------------------------------------------------*/

/* The OUTPUT_ARCH command specifies the machine architecture where the
   argument is one of the names used in the BFD library. More
   specifically one of the entires in bfd/cpu-mips.c */

OUTPUT_ARCH( "riscv" )
ENTRY(rvtest_entry_point)

MEMORY
{
  ram  : ORIGIN = 0x0, LENGTH = 1M
}

/*----------------------------------------------------------------------*/
/* Sections                                                             */
/*----------------------------------------------------------------------*/

SECTIONS
{

  /* text: test code section */
  .text.init : {
    . = 0x0;
    *(.text.init)
  } > ram

  .text : { *(.text) } > ram

  /* data segment */
  .rodata : { *(.rodata) } > ram

  /* data segment */
  .data : { *(.data) } > ram

  .sdata : {
    __global_pointer$ = . + 0x800;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
  } > ram

  /* bss segment */
  .sbss : {
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
  } > ram
  .bss : { *(.bss) } > ram

  /* thread-local data segment */
  .tdata :
  {
    _tdata_begin = .;
    *(.tdata)
    _tdata_end = .;
  } > ram
  .tbss :
  {
    *(.tbss)
    _tbss_end = .;
    /* End of uninitalized data segement */
    _end = .;
  } > ram

  .tohost : {
    . = ALIGN(0x1000);
    *(.tohost)
  } > ram
}
