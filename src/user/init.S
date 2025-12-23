.intel_syntax noprefix

.global init

init:
    int 0x80
    xor ebx, ebx
    int 0x80
