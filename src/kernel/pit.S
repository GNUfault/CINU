.intel_syntax noprefix

.global pit_init
pit_init:
    push eax
    push edi
    
    lea edi, [idt + 0x20 * 8]
    lea eax, [pit_handler]
    mov dx, ax
    shr eax, 16
    mov [edi], dx
    mov [edi + 2], word ptr 0x0008
    mov [edi + 4], word ptr 0x8E00
    mov [edi + 6], ax
    
    mov al, 0x36
    out 0x43, al
    
    mov ax, 1193
    out 0x40, al
    mov al, ah
    out 0x40, al
    
    in al, 0x21
    and al, 0xFE
    out 0x21, al
    
    pop edi
    pop eax
    ret

pit_handler:
    push eax
    
    inc dword ptr [tick_count]
    
    mov al, 0x20
    out 0x20, al

    push offset msg
    call printk

    pop eax
    iret

.section .data
.global tick_count
tick_count:
    .long 0
msg:
    .asciz "tick\n"

.extern idt
