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

#include "pic.h"
#include "io.h"

void pic_remap(void) {
    // ICW1: Init
    outb(PIC1_COMMAND, 0x11);
    outb(PIC2_COMMAND, 0x11);

    // ICW2: Vector offsets (Master=32, Slave=40)
    outb(PIC1_DATA, 0x20);
    outb(PIC2_DATA, 0x28);

    // ICW3: Cascading
    outb(PIC1_DATA, 0x04);
    outb(PIC2_DATA, 0x02);

    // ICW4: 8086 mode
    outb(PIC1_DATA, 0x01);
    outb(PIC2_DATA, 0x01);

    // Mask everything by default (0xFF)
    outb(PIC1_DATA, 0xFF);
    outb(PIC2_DATA, 0xFF);
}

void irq_clear_mask(unsigned char irq) {
    unsigned short port;
    if(irq < 8) {
        port = PIC1_DATA;
    } else {
        port = PIC2_DATA;
        irq -= 8;
    }
    unsigned char value = inb(port) & ~(1 << irq);
    outb(port, value);
}

void pic_send_eoi(unsigned char irq) {
    if(irq >= 8) outb(PIC2_COMMAND, PIC_EOI);
    outb(PIC1_COMMAND, PIC_EOI);
}
