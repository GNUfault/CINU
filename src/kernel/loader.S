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

.global load_user

.extern ata_load

load_user:
    push 0x00080000
    push 65
    push 32
    call ata_load
    add esp, 12

    mov esi, 0x00080000
    cmp dword ptr [esi], 0x464C457F
    jne fail

    mov ebx, [esi+28]
    add ebx, esi
    mov ecx, [esi+44]

ph_loop:
    cmp ecx, 0
    je done

    mov edx, [ebx]
    cmp edx, 1
    jne next

    mov eax, [ebx+4]
    add eax, 0x00080000
    mov edi, [ebx+8]
    mov edx, [ebx+16]
    mov ecx, edx
    rep movsb

    mov ecx, [ebx+20]
    sub ecx, edx
    jle next
    xor eax, eax
    rep stosb

next:
    add ebx, [esi+42]
    dec ecx
    jmp ph_loop

done:
    ret

fail:
    ret
