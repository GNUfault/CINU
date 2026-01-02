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

#include "idt.h"
#include "idt_s.h"

// IDT entry
struct idt_entry {
    unsigned short base_low;
    unsigned short selector;
    unsigned char zero;
    unsigned char flags;
    unsigned short base_high;
} __attribute__((packed));

// IDT pointer
struct idt_ptr {
    unsigned short limit;
    unsigned int base;
} __attribute__((packed));

static struct idt_entry idt[256];
static struct idt_ptr idtr;

// Set an IDT gate
void idt_set_gate(unsigned char num, unsigned int base, 
                  unsigned short selector, unsigned char flags) {
    idt[num].base_low = (base & 0xFFFF);
    idt[num].base_high = (base >> 16) & 0xFFFF;

    idt[num].selector = selector;
    idt[num].zero = 0;
    idt[num].flags = flags;
}

// Initialize the IDT
void idt_init(void) {
    int i;

    // Set up the IDT pointer
    idtr.limit = (sizeof(struct idt_entry) * 256) - 1;
    idtr.base = (unsigned int)&idt;

    // Clear out the IDT
    for (i = 0; i < 256; i++) {
        idt_set_gate(i, 0, 0, 0);
    }

    // Load the IDT
    idt_flush((unsigned int)&idtr);
}
