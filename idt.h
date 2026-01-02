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

#ifndef IDT_H
#define IDT_H

// IDT flags
#define IDT_PRESENT 0x80
#define IDT_DPL0 0x00
#define IDT_DPL1 0x20
#define IDT_DPL2 0x40
#define IDT_DPL3 0x60
#define IDT_INT_GATE 0x0E
#define IDT_TRAP_GATE 0x0F

// Common gate types
#define IDT_GATE_INT_RING0  (IDT_PRESENT | IDT_DPL0 | IDT_INT_GATE)
#define IDT_GATE_INT_RING3  (IDT_PRESENT | IDT_DPL3 | IDT_INT_GATE)
#define IDT_GATE_TRAP_RING0 (IDT_PRESENT | IDT_DPL0 | IDT_TRAP_GATE)
#define IDT_GATE_TRAP_RING3 (IDT_PRESENT | IDT_DPL3 | IDT_TRAP_GATE)

void idt_init(void);
void idt_set_gate(unsigned char num, unsigned int base, 
                  unsigned short selector, unsigned char flags);

#endif
