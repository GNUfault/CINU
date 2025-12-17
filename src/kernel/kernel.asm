[BITS 32]

global _start

extern clear_screen
extern panic
extern nasm_version
extern build_date
extern printk

_start:
    call clear_screen

    push one
    call printk
    add esp, 4

    push nasm_version
    call printk
    add esp, 4

    push two
    call printk
    add esp, 4

    push build_date
    call printk
    add esp, 4

    push newline
    call printk
    add esp, 4

    push string_panic_msg
    call panic
    add esp, 4

section .rodata
string_panic_msg db "Nothing else implemented (yet)", 10, 0
one             db "CINUX (Built with: ", 0
two             db ") Built on: ", 0
newline         db 10, 0
