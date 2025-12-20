.intel_syntax noprefix
.section .text
.global printk

printk:
    mov esi, 0x5000
    mov edi, [esi]

    mov ecx, 1024*768

.fill:
    mov byte ptr [edi], 0xFF
    mov byte ptr [edi+1], 0x00
    mov byte ptr [edi+2], 0x00
    add edi, 3
    loop .fill

    ret
