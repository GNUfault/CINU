.intel_syntax noprefix
.section .data
.align 16
idt:
    .rept 256
    .word 0
    .word 0x08
    .byte 0
    .byte 0x8E
    .word 0
    .endr

idt_ptr:
    .word 256 * 8 - 1
    .long idt

.section .data
frame_counter: .long 0

.section .text
.global idt_setup
.global irq0_handler
.extern pit_ticks
.extern logo_angle
.extern update_logo

idt_setup:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    
    lea eax, [irq0_handler]
    lea ebx, [idt + 32*8]
    
    mov word ptr [ebx], ax
    shr eax, 16
    mov word ptr [ebx+6], ax
    
    mov eax, 0x20
    out 0x20, al
    out 0xA0, al
    
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
    out 0xA1, al
    
    lidt [idt_ptr]
    
    pop ebx
    pop eax
    pop ebp
    ret

irq0_handler:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    
    inc dword ptr [pit_ticks]
    inc dword ptr [frame_counter]
    
    mov eax, [frame_counter]
    cmp eax, 20
    jb .no_update
    
    mov dword ptr [frame_counter], 0
    mov eax, [logo_angle]
    add eax, 5
    and eax, 0xFF
    mov [logo_angle], eax
    
.no_update:
    mov al, 0x20
    out 0x20, al
    
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    iret
