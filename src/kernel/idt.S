/*
 * CINUX
 * Copyright (C) 2025 Connor Thomson
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

.intel_syntax noprefix

.global idt_init
.extern isr_stub_table
.extern irq_stub_table
.extern syscall_handler
.extern printk

.section .rodata
msg_idt_start:
    .asciz "Initializing IDT...\n"
msg_idt_isr: 
    .asciz "Initializing ISR...\n"
msg_idt_irq:
    .asciz "Initializing IRQ...\n"
msg_idt_lidt:
    .asciz "Initializing IDTR...\n"
msg_idt_pic:
    .asciz "Remapping PIC...\n"
msg_idt_sti:
    .asciz "Enabling interrupts...\n"

.section .text

idt_init:
    push offset msg_idt_start
    call printk
    add esp, 4

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

    push offset msg_idt_isr
    call printk
    add esp, 4

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

    push offset msg_idt_irq
    call printk
    add esp, 4

    mov eax, offset syscall_handler
    mov edi, idt
    lea edi, [edi + 0x80*8]
    mov dx, ax
    shr eax, 16
    mov word ptr [edi], dx
    mov word ptr [edi + 2], 0x0008
    mov word ptr [edi + 4], 0xEE00
    mov word ptr [edi + 6], ax

    push offset msg_idt_lidt
    call printk
    add esp, 4

    lidt [idt_ptr]

    push offset msg_idt_pic
    call printk
    add esp, 4

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

    push offset msg_idt_sti
    call printk
    add esp, 4
 
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
