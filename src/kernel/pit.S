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

.global pit_init

.extern idt

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
    pushad
    
    inc dword ptr [tick_count]
    
    # Put what you would like to do here
    
    mov al, 0x20
    out 0x20, al
    
    popad
    iret

.section .data
.global tick_count
tick_count:
    .long 0
