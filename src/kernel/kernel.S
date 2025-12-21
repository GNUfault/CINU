.intel_syntax noprefix

.extern panic
.extern setup_idt
.extern serial_init
.extern pit_init
.extern keyboard_init

.section .rodata
msg:
    .asciz "Nothing else implemented (yet)\n"

.section .text
.global _start
_start:
    sti

    call idt_init
    call serial_init
    call pit_init
    call keyboard_init

    push offset msg
    call panic
