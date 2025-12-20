.intel_syntax noprefix
.code32

.extern fb_addr

.global printk

printk:
    mov esi, [fb_addr]
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
