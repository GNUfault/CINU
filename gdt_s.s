/*
 * CINUX
 * Copyright (C) 2025-2026 Connor Thomson
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

.global gdt_flush
gdt_flush:
    mov eax, [esp+4] # Get the pointer to the GDT pointer
    lgdt [eax]       # Load the GDT

    mov ax, 0x10 # 0x10 is the offset to our data segment
    mov ds, ax   # Load all data segment selectors
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    # 0x08 is the offset to our code segment
    # Far jump to flush the instruction pipeline
    jmp 0x08:flush_cs 

flush_cs:
    ret
