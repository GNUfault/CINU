.intel_syntax noprefix

.section .multiboot
.align 4
.long 0x1BADB002
.long 0x00000003
.long -(0x1BADB002 + 0x00000003)

.section .bootstrap_stack, "aw", @nobits
stack_bottom:
.skip 16384
stack_top:

.section .text
.global _start
.extern kmain

_start:
    mov esp, offset stack_top

    push ebx
    push eax

    call kmain
