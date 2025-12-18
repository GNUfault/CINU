ENTRY(_start)
OUTPUT_FORMAT("binary")
OUTPUT_ARCH(i386)

SECTIONS {
  . = 0x00090000;

  .text : {
    *(.text*)
    *(.rodata*)
  }

  .data : {
    *(.data*)
  }

  .bss : {
    *(.bss*)
    *(COMMON)
  }
}
