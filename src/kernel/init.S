.intel_syntax noprefix

.global init

init:
    push msg
    mov eax, 0
    mov ebx, [esp + 4]
    int 0x80
    add esp, 4

.section .data
msg:
    .asciz "Hello, worl- I mean user mode!\n"

