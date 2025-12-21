.intel_syntax noprefix

.extern panic
.extern idt_setup
.extern pit_setup

.section .rodata
msg:
    .asciz "Nothing else implemented (yet)\n"

.section .text
.global _start
_start:
    push offset msg
    call panic
