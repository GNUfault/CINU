.intel_syntax noprefix
.section .text
.extern printk
.global keyboard_init
keyboard_init:
    push eax
    push edi
    
    lea edi, [idt + 0x21 * 8]
    lea eax, [keyboard_handler]
    mov dx, ax
    shr eax, 16
    mov [edi], dx
    mov [edi + 2], word ptr 0x0008
    mov [edi + 4], word ptr 0x8E00
    mov [edi + 6], ax
    
    in al, 0x21
    and al, 0xFD
    out 0x21, al
    
    pop edi
    pop eax
    ret

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

.extern idt
