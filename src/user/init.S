.intel_syntax noprefix
.code32

.globl init

init:
    int 0x80
    xor ebx, ebx
    int 0x80
