ENTRY(init)
OUTPUT_ARCH(i386)
OUTPUT_FORMAT("elf32-i386")

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
