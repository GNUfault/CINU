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
.extern pmt_schedule

irq0_stub:
    # Save the current task's state
    pushad
    push ds
    push es
    push fs
    push gs

    # Pass the current stack pointer (ESP) to the scheduler
    push esp
    call pmt_schedule
    # The scheduler returns the NEW stack pointer in EAX
    mov esp, eax

    # Acknowledge the interrupt
    mov al, 0x20
    out 0x20, al

    # Restore the NEW task's state
    pop gs
    pop fs
    pop es
    pop ds
    popad
    iret
