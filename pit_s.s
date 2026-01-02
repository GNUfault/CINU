/*
 * CINUX
 * Copyright (C) 2025-2026 Connor Thomson
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
.global irq0_stub
.extern pit_handler

irq0_stub:
    pushad
    push ds
    push es
    push fs
    push gs

    mov ax, 0x10
    mov ds, ax
    mov es, ax

    call pit_handler

    # Send EOI specifically to Master PIC (IRQ 0 is always Master)
    mov al, 0x20
    out 0x20, al

    pop gs
    pop fs
    pop es
    pop ds
    popad
    iret
