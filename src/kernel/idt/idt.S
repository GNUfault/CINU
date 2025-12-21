.intel_syntax noprefix
.section .text

.global setup_idt
setup_idt:
    lea edi, [idt]
    mov ecx, 256
    lea eax, [default_handler]
    mov dx, ax
    shr eax, 16
    mov bx, 0x08
    or bx, 0x8E00
clear_idt:
    mov [edi], dx
    mov [edi + 2], bx
    mov [edi + 4], ax
    mov [edi + 6], word ptr 0
    add edi, 8
    loop clear_idt
    
    lea edi, [idt + 0x21 * 8]
    lea eax, [keyboard_handler]
    mov dx, ax
    shr eax, 16
    mov [edi], dx
    mov [edi + 2], word ptr 0x0008
    mov [edi + 4], word ptr 0x8E00
    mov [edi + 6], ax
    
    lidt [idt_ptr]
    
    mov al, 0x11
    out 0x20, al
    out 0xA0, al
    
    mov al, 0x20
    out 0x21, al
    mov al, 0x28
    out 0xA1, al
    
    mov al, 0x04
    out 0x21, al
    mov al, 0x02
    out 0xA1, al
    
    mov al, 0x01
    out 0x21, al
    out 0xA1, al
    
    mov al, 0xFD
    out 0x21, al
    mov al, 0xFF
    out 0xA1, al
    
    sti
    ret

default_handler:
    iret

keyboard_handler:
    pusha
    
    in al, 0x60
    
    cmp al, 0x80
    jae kb_done
    
    movzx ebx, al
    lea esi, [scancode_table]
    mov al, [esi + ebx]
    
    cmp al, 0
    je kb_done
    
    mov [key_buffer], al
    mov byte ptr [key_buffer + 1], 0
    
    lea eax, [key_buffer]
    push eax
    call printk
    add esp, 4

kb_done:
    mov al, 0x20
    out 0x20, al
    
    popa
    iret

.section .data
idt_ptr:
    .word 2048 - 1
    .long idt

scancode_table:
    .byte 0, 0x1B, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0x08, 0x09
    .byte 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0x0A, 0
    .byte 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`', 0, '\\'
    .byte 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' '

key_buffer:
    .skip 2

.section .bss
idt:
    .skip 2048
