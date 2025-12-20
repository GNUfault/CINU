.intel_syntax noprefix

.extern panic

.global _start

_start:
    push offset msg
    call panic

.section .rodata
msg:
    .asciz "Nothing else implemented (yet)\n"
