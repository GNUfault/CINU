.intel_syntax noprefix
.code32

.section .text
.global printk

printk: # Placeholder
    mov esi, 0xE0000000
    mov edx, 0x12345678

draw_loop:
    mov eax, edx
    imul eax, 1103515245
    add eax, 12345
    mov edx, eax
    shr eax, 16
    mov word ptr [esi], ax
    add esi, 2
    jmp draw_loop
