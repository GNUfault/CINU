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
.section .multiboot
.align 4

multiboot_header:
    .long 0x1BADB002
    .long 0x00000003
    .long -(0x1BADB002 + 0x00000003)

.section .text
.global _start

_start:
    cli
    
    mov ax, 0x4F02
    mov bx, 0x4118
    int 0x10
    
    cmp ax, 0x004F
    jne vbe_fail
    
    mov ax, 0x4F01
    mov cx, 0x4118
    mov di, offset vbe_mode_info
    int 0x10
    
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    jmp 0x08:protected_mode

vbe_fail:
    hlt
    jmp vbe_fail

protected_mode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    mov esp, 0x90000
    
    mov eax, [vbe_mode_info + 40]
    push eax
    
    call kmain
    
hang:
    hlt
    jmp hang

.align 16
gdt_start:
    .quad 0x0000000000000000
    
gdt_code:
    .word 0xFFFF
    .word 0x0000
    .byte 0x00
    .byte 0b10011010
    .byte 0b11001111
    .byte 0x00
    
gdt_data:
    .word 0xFFFF
    .word 0x0000
    .byte 0x00
    .byte 0b10010010
    .byte 0b11001111
    .byte 0x00

gdt_end:

gdt_descriptor:
    .word gdt_end - gdt_start - 1
    .long gdt_start

.section .bss
.align 256
vbe_mode_info:
    .skip 256
