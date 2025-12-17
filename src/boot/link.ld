OUTPUT_FORMAT("binary")
OUTPUT_ARCH(i386)

SECTIONS {
  . = 0x7C00;
  .text : { *(.text) }
  .data : { *(.data) }
  .bss  : { *(.bss) }
}
