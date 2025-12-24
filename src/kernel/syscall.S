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
    .long sys_printk

.section .text
syscall_handler:
    push eax
    push gs
    push fs
    push es
    push ds
    push -38
    push ebp
    push edi
    push esi
    push edx
    push ecx
    push ebx
    push esp
    call syscall_dispatcher
    add esp, 4
    pop ebx
    pop ecx
    pop edx
    pop esi
    pop edi
    pop ebp
    add esp, 4
    pop ds
    pop es
    pop fs
    pop gs
    pop eax
    iretd

syscall_dispatcher:
    mov edx, eax
    cmp edx, NR_SYSCALLS
    jae .bad
    mov eax, [syscall_table + edx*4]
    call eax
    ret
.bad:
    mov eax, -38
    ret
