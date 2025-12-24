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

.global tss_entry
.global tss_init
.global flush_tss
.extern printk

.section .bss
.align 16
tss_entry:
    .space 104

.section .text

tss_init:
    push eax

    push offset msg_init_tss
    call printk
    add esp, 4

    mov ecx, 104
    mov edi, offset tss_entry
    xor eax, eax
    rep stosb

    mov eax, 0x00900000
    mov dword ptr [tss_entry + 4], eax

    mov eax, 0x10
    mov dword ptr [tss_entry + 8], eax

    mov word ptr [tss_entry + 102], 104

    mov ax, (5 * 8)
    ltr ax

    pop eax
    ret

.section .data
msg_init_tss:
    .asciz "Initializing TSS...\n"
