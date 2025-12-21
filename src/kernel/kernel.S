.intel_syntax noprefix

.extern panic
.extern enable_paging
.extern setup_idt
.extern serial_init
.extern pit_init

.section .rodata
msg:
    .asciz "Nothing else implemented (yet)\n"

.section .text
.global _start
_start:
    sti
#    call enable_paging
    call serial_init
    call setup_idt
    call pit_init

    push offset msg
    call panic
