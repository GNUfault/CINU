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

#include "gdt.h"
#include "gdt_s.h"

// GDT entry 
struct gdt_entry {
    unsigned short limit_low;
    unsigned short base_low;
    unsigned char base_middle;
    unsigned char access;
    unsigned char granularity;
    unsigned char base_high;
} __attribute__((packed));

// GDT pointer
struct gdt_ptr {
    unsigned short limit;
    unsigned int base;
} __attribute__((packed));

static struct gdt_entry gdt[3];
static struct gdt_ptr gdtr;

// Set a GDT entry
static void gdt_set_gate(int num, unsigned int base, unsigned int limit,
                         unsigned char access, unsigned char gran) {
    gdt[num].base_low = (base & 0xFFFF);
    gdt[num].base_middle = (base >> 16) & 0xFF;
    gdt[num].base_high = (base >> 24) & 0xFF;

    gdt[num].limit_low = (limit & 0xFFFF);
    gdt[num].granularity = ((limit >> 16) & 0x0F) | (gran & 0xF0);

    gdt[num].access = access;
}

// Initialize the GDT
void gdt_init(void) {
    // Set up the GDT pointer
    gdtr.limit = (sizeof(struct gdt_entry) * 3) - 1;
    gdtr.base = (unsigned int)&gdt;

    // Null descriptor
    gdt_set_gate(0, 0, 0, 0, 0);

    // Code segment: base=0, limit=4GB, access=0x9A, granularity=0xCF
    // Access: Present, Ring 0, Code, Executable, Readable
    // Granularity: 4KB blocks, 32-bit
    gdt_set_gate(1, 0, 0xFFFFFFFF, 0x9A, 0xCF);

    // Data segment: base=0, limit=4GB, access=0x92, granularity=0xCF
    // Access: Present, Ring 0, Data, Writable
    // Granularity: 4KB blocks, 32-bit
    gdt_set_gate(2, 0, 0xFFFFFFFF, 0x92, 0xCF);

    // Load the GDT and update segment registers
    gdt_flush((unsigned int)&gdtr);
}
