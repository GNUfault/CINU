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

.global gdt_init

.extern tss_entry
.extern printk

.section .data
msg_init:
    .asciz "Initializing GDT...\n"
msg_tss:
    .asciz "Initializing TSS...\n"
gdt:
    .word 0x0000, 0x0000
    .byte 0x00, 0x00, 0x00, 0x00
    .word 0xFFFF, 0x0000
    .byte 0x00, 0x9A, 0xCF, 0x00
    .word 0xFFFF, 0x0000
    .byte 0x00, 0x92, 0xCF, 0x00
    .word 0xFFFF, 0x0000
    .byte 0x00, 0xFA, 0xCF, 0x00
    .word 0xFFFF, 0x0000
    .byte 0x00, 0xF2, 0xCF, 0x00
    .word 0x0000, 0x0000
    .byte 0x00, 0x00, 0x00, 0x00
gdt_descriptor:
    .word (gdt_end - gdt - 1)
    .long gdt
gdt_end:

.section .text
gdt_init:
    push offset msg_tss
    call printk
    add esp, 4

    mov eax, offset tss_entry
    mov ebx, offset gdt
    add ebx, 40

    mov cx, 104
    mov [ebx], cx
    mov cx, ax
    mov [ebx+2], cx
    shr eax, 16
    mov cl, al
    mov [ebx+4], cl
    mov byte ptr [ebx+5], 0x89
    mov byte ptr [ebx+6], 0x00
    mov cl, ah
    mov [ebx+7], cl

    push offset msg_init
    call printk
    add esp, 4

    mov eax, offset gdt_descriptor
    lgdt [eax]

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ret
