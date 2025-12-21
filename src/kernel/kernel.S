.intel_syntax noprefix

.extern panic
.extern enable_paging
.extern setup_idt

.section .rodata
msg:
    .asciz "Nothing else implemented (yet)\n"

.section .text
.global _start
_start:
    sti
#    call enable_paging
    call setup_idt

    push offset msg
    call panic
