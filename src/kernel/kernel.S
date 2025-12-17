.intel_syntax noprefix
.globl _start

.extern clear_screen
.extern panic
.extern gas_version
.extern build_date

_start:
    call clear_screen

    mov esi, offset gas_version
    call printk

    mov esi, offset build_date
    call printk

    mov esi, offset newline
    call printk

    push offset string_panic_msg
    call panic
    add esp, 4

.section .rodata
string_panic_msg:
    .asciz "Nothing else implemented (yet)\n"
newline:   
    .asciz "\n"
