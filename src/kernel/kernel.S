.intel_syntax noprefix
.globl _start

.extern clear_screen
.extern panic
.extern gas_version
.extern build_date

_start:
    call clear_screen

    push offset gas_version 
    call printk
    add esp, 4

    push offset build_date
    call printk
    add esp, 4

    push offset newline
    call printk
    add esp, 4

    push offset string_panic_msg
    call panic
    add esp, 4

.section .rodata
string_panic_msg:
    .asciz "Nothing else implemented (yet)\n"
newline:   
    .asciz "\n"
