ENTRY(init)
OUTPUT_FORMAT("binary")
OUTPUT_ARCH(i386)

SECTIONS {
  . = 0x00080000;

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
