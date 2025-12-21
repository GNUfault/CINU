.intel_syntax noprefix
.section .text
.global setup_idt
setup_idt:
    lea edi, [idt]
    mov ecx, 256
    lea eax, [default_handler]
    mov dx, ax
    shr eax, 16
clear_idt:
    mov [edi], dx
    mov [edi + 2], word ptr 0x0008
    mov [edi + 4], word ptr 0x8E00
    mov [edi + 6], ax
    add edi, 8
    loop clear_idt
    
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
    
    mov al, 0xFF
    out 0x21, al
    mov al, 0xFF
    out 0xA1, al
    
    sti
    ret

default_handler:
    iret

.section .data
idt_ptr:
    .word 2048 - 1
    .long idt

.section .bss
.global idt
idt:
    .skip 2048
