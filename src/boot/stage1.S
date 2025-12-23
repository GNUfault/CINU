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
.code16

.section .text
.global start

start:
    cli
    xor cx, cx
    mov ss, cx
    mov sp, 0x7C00
    mov ds, cx
    
    mov ah, 0x41
    mov bx, 0x55AA
    int 0x13
    jc no_lba_support
    
    mov si, offset dap
    mov word ptr [si], 0x10
    mov word ptr [si + 2], 2
    mov word ptr [si + 4], 0x7E00
    mov word ptr [si + 6], 0
    mov dword ptr [si + 8], 1
    mov dword ptr [si + 12], 0
    
    mov ah, 0x42
    int 0x13
    jc load_fail
    
    jmp 0x7E00

print:
    cld
    mov ah, 0x0E
    mov bx, 0x0007
.loop:
    lodsb
    test al, al
    jz .ret
    int 0x10
    jmp .loop
.ret:
    ret

no_lba_support:
    mov si, offset msg_no_lba
    call print
    cli
    hlt

load_fail:
    mov si, offset msg_load_fail
    call print
    cli
    hlt

dap:
    .word 0x10
    .word 0
    .word 0
    .word 0
    .quad 0

msg_no_lba:
    .asciz "Error: LBA not supported!"

msg_load_fail:
    .asciz "Error: failed to load stage2!"

.space 0x200 - 2 - (. - start)
.word 0xaa55
