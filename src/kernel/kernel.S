.intel_syntax noprefix
.global _start

.extern panic

_start:
    push offset msg
    call panic

.section .rodata
msg:
    .asciz "Nothing else implemented (yet)\n"
