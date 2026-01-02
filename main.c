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

#include "vga.h"
#include "gdt.h"
#include "idt.h"
#include "pic.h"
#include "pit.h"

void kmain(void) {
    clear_screen();
   
    printk("Initializing GDT... ");
    gdt_init();
    printk("ok.\n");

    printk("Initializing IDT... ");
    idt_init();
    printk("ok.\n");

    printk("Initializing PIC... ");
    pic_init();
    printk("ok.\n");

    printk("Initializing PIT... );
    pit_init();
    printk("ok.\n");
    
    for (;;); // Loop forever for now
}
