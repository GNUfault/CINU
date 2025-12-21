.intel_syntax noprefix

.extern panic
.extern setup_idt
.extern serial_init
.extern pit_init
.extern keyboard_init
.extern enable_paging
.extern floppy_init

.extern print_bytes

.section .rodata
msg:
    .asciz "Nothing else implemented (yet)\n"

.section .text
.global _start
_start:
    sti

    call enable_paging
    call idt_init
    call serial_init
    call pit_init
    call keyboard_init
    call floppy_init

#    call print_bytes

    push offset msg
    call panic
