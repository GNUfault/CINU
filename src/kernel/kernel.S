.intel_syntax noprefix
.globl _start

.extern clear_screen
.extern panic
.extern floppy_init

_start:
    call clear_screen

    call floppy_init

    push offset string_panic_msg
    call panic
    add esp, 4

.section .rodata
string_panic_msg:
    .asciz "Nothing else implemented (yet)\n"
