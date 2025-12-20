.intel_syntax noprefix
.global _start

.extern panic
.extern draw_logo

_start:
    call draw_logo

    push offset msg
    call panic

.section .rodata
msg:
    .asciz "Nothing else implemented (yet)\n"
