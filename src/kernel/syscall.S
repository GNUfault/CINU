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

.global syscall_handler
.extern printk

.section .data
syscall_table:
    .long sys_print

.section .text

syscall_handler:
    pusha
    push ds
    push es
    push fs
    push gs

    mov ax, 0x10
    mov ds, ax
    mov es, ax

    cmp eax, 0
    jne sys_invalid

    mov eax, [syscall_table]
    call eax
    jmp sys_return

sys_invalid:
    jmp sys_return

sys_print:
    push ebx
    call printk
    add esp, 4
    ret

sys_return:
    pop gs
    pop fs
    pop es
    pop ds
    popa
    iretd
