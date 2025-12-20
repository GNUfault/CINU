.intel_syntax noprefix
.global _start

.extern clear_screen
.extern panic

_start:
    push offset string_panic_msg
    call panic
    add esp, 4

.section .rodata
string_panic_msg:
    .asciz "Nothing else implemented (yet)\n"
