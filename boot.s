/*
 * CINUX
 * Copyright (C) 2025 Connor Thomson
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
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

.align 4
multiboot_header:
    .long 0x1BADB002
    .long 0x00000004
    .long -(0x1BADB002 + 0x00000004)
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 1024
    .long 768
    .long 24

.global _start
_start:
    mov esp, offset stack_top
    push ebx
    push eax
    call kmain
    cli
.hang:
    hlt
    jmp .hang

.section .bss
.align 16
stack_bottom:
    .skip 16384
stack_top:
