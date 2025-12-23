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
.global panic

panic:
    push ebp
    mov ebp, esp

    push offset panic_msg
    call printk
    add esp, 4

    push dword ptr [ebp + 8]
    call printk
    add esp, 4

    pop ebp
    cli
.loop:
    hlt
    jmp .loop

.section .rodata
panic_msg:
    .asciz "PANIC: "
