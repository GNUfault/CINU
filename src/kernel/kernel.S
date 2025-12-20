.intel_syntax noprefix

.extern panic

.section .rodata
msg:
    .asciz "Nothing else implemented (yet)\n"

.section .text
.global _start
_start:
    push offset msg
    call panic
