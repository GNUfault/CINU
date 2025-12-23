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
.global GDT_KERNEL_CODE
.global GDT_KERNEL_DATA
.global GDT_USER_CODE
.global GDT_USER_DATA

.equ GDT_NULL,        0x00
.equ GDT_KERNEL_CODE, 0x08
.equ GDT_KERNEL_DATA, 0x10
.equ GDT_USER_CODE,   0x18
.equ GDT_USER_DATA,   0x20
.equ GDT_TSS,         0x28

.extern tss_entry

.section .data
gdt:
    .word 0x0000
    .word 0x0000
    .byte 0x00
    .byte 0x00
    .byte 0x00
    .byte 0x00

    .word 0xFFFF
    .word 0x0000
    .byte 0x00
    .byte 0x9A
    .byte 0xCF
    .byte 0x00

    .word 0xFFFF
    .word 0x0000
    .byte 0x00
    .byte 0x92
    .byte 0xCF
    .byte 0x00

    .word 0xFFFF
    .word 0x0000
    .byte 0x00
    .byte 0xFA
    .byte 0xCF
    .byte 0x00

    .word 0xFFFF
    .word 0x0000
    .byte 0x00
    .byte 0xF2
    .byte 0xCF
    .byte 0x00

    .word 0x0000
    .word 0x0000
    .byte 0x00
    .byte 0x00
    .byte 0x00
    .byte 0x00

gdt_descriptor:
    .word (gdt_end - gdt - 1)
    .long gdt

gdt_end:

.section .text

gdt_init:
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

    mov eax, offset gdt_descriptor
    lgdt [eax]

    mov ax, GDT_KERNEL_DATA
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp GDT_KERNEL_CODE:flush_cs

flush_cs:
    ret
