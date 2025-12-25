.intel_syntax noprefix

.extern printk

.global print_bytes

.section .data
hex_digits:
    .asciz "0123456789ABCDEF"

.section .bss
.align 4
hex_buffer:
    .space 2048

.section .text

print_bytes:
    pushad

    mov esi, 0x00080000
    mov ecx, 512
    mov edi, hex_buffer

next_byte:
    mov bl, [esi]
    mov edx, hex_digits

    mov al, bl
    shr al, 4
    mov al, [edx+eax]
    mov [edi], al
    inc edi

    mov al, bl
    and al, 0x0F
    mov al, [edx+eax]
    mov [edi], al
    inc edi

    mov byte ptr [edi], ' '
    inc edi

    inc esi
    loop next_byte

    mov byte ptr [edi], 0

    push offset hex_buffer
    call printk
    add esp, 4

    popad
    ret
