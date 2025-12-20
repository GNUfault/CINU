.intel_syntax noprefix

.extern panic
.extern boot_logo

.section .rodata
msg:
    .asciz "Nothing else implemented (yet)\n"

.section .text
.global _start
_start:
    call boot_logo
    
    push offset msg
    call panic
