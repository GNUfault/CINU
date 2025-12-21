.intel_syntax noprefix
.section .text
.extern printk
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
    
    lea edi, [idt + 0x20 * 8]
    lea eax, [pit_handler]
    mov dx, ax
    shr eax, 16
    mov [edi], dx
    mov [edi + 2], word ptr 0x0008
    mov [edi + 4], word ptr 0x8E00
    mov [edi + 6], ax
    
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
    
    mov al, 0x36
    out 0x43, al
    
    mov ax, 1193
    out 0x40, al
    mov al, ah
    out 0x40, al
    
    mov al, 0xFC
    out 0x21, al
    mov al, 0xFF
    out 0xA1, al
    
    sti
    ret

default_handler:
    iret

pit_handler:
    push eax
    
    inc dword ptr [tick_count]
    
    mov al, 0x20
    out 0x20, al
    
    pop eax
    iret

keyboard_handler:
    push eax
    push ebx
    push ecx
    push edx
    
    in al, 0x60
    
    push offset key_msg
    call printk
    add esp, 4
    
    mov al, 0x20
    out 0x20, al
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    iret

.section .rodata
key_msg:
    .asciz "key\n"

.section .data
idt_ptr:
    .word 2048 - 1
    .long idt

.global tick_count
tick_count:
    .long 0

.section .bss
idt:
    .skip 2048
