.intel_syntax noprefix
.global _start

.extern panic

_start:
    call printk

.section .rodata
string_panic_msg:
    .asciz "Nothing else implemented (yet)\n"
