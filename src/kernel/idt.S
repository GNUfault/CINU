.intel_syntax noprefix
.code32

.global idt_init
.extern isr_stub_table
.extern irq_stub_table
.extern syscall_handler

.section .text

idt_init:
    lea edi, idt
    mov ecx, 256
    lea eax, default_handler
    mov dx, ax
    shr eax, 16
clear_idt:
    mov word ptr [edi], dx
    mov word ptr [edi + 2], 0x0008
    mov word ptr [edi + 4], 0x8E00
    mov word ptr [edi + 6], ax
    add edi, 8
    loop clear_idt

    mov ecx, 32
    xor ebx, ebx
set_isrs:
    mov eax, dword ptr [isr_stub_table + ebx*4]
    mov edi, idt
    lea edi, [edi + ebx*8]
    mov dx, ax
    shr eax, 16
    mov word ptr [edi], dx
    mov word ptr [edi + 2], 0x0008
    mov word ptr [edi + 4], 0x8E00
    mov word ptr [edi + 6], ax
    inc ebx
    loop set_isrs

    mov ecx, 16
    mov ebx, 32
set_irqs:
    mov eax, dword ptr [irq_stub_table + (ebx-32)*4]
    mov edi, idt
    lea edi, [edi + ebx*8]
    mov dx, ax
    shr eax, 16
    mov word ptr [edi], dx
    mov word ptr [edi + 2], 0x0008
    mov word ptr [edi + 4], 0x8E00
    mov word ptr [edi + 6], ax
    inc ebx
    loop set_irqs

    mov eax, offset syscall_handler
    mov edi, idt
    lea edi, [edi + 0x80*8]
    mov dx, ax
    shr eax, 16
    mov word ptr [edi], dx
    mov word ptr [edi + 2], 0x0008
    mov word ptr [edi + 4], 0xEE00
    mov word ptr [edi + 6], ax

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

    mov al, 0x00
    out 0x21, al
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
