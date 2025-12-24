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
.extern idt
.extern printk
.global serial_init
.global serial_console_write

serial_init:
    push eax
    push edi

    push offset msg_init_serial
    call printk

    mov dx, 0x3F8 + 1
    mov al, 0x00
    out dx, al

    mov dx, 0x3F8 + 3
    mov al, 0x80
    out dx, al

    mov dx, 0x3F8 + 0
    mov al, 0x03
    out dx, al

    mov dx, 0x3F8 + 1
    mov al, 0x00
    out dx, al

    mov dx, 0x3F8 + 3
    mov al, 0x03
    out dx, al

    mov dx, 0x3F8 + 2
    mov al, 0xC7
    out dx, al

    mov dx, 0x3F8 + 4
    mov al, 0x0B
    out dx, al

    push offset msg_init_idt
    call printk

    lea edi, [idt + 0x24 * 8]
    lea eax, [serial_handler]
    mov dx, ax
    shr eax, 16
    mov [edi], dx
    mov [edi + 2], word ptr 0x0008
    mov [edi + 4], word ptr 0x8E00
    mov [edi + 6], ax

    push offset msg_enable_irq
    call printk

    mov dx, 0x3F8 + 1
    mov al, 0x02
    out dx, al

    in al, 0x21
    and al, 0xEF
    out 0x21, al

    pop edi
    pop eax
    ret

.section .data
msg_init_serial:
    .asciz "Initializing serial...\n"
msg_init_idt:
    .asciz "Initializing serial IDT...\n"
msg_enable_irq:
    .asciz "Enabling serial IRQ...\n"
