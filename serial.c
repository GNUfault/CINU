/*
 * CINUX
 * Copyright (C) 2025 Connor Thomson
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
#include "idt.h"
#include "io.h"
#include "cpu.h"

static unsigned int write_buffer_read = 0;
static unsigned int write_buffer_write = 0;
static unsigned char write_buffer[4096];

__attribute__((interrupt))
static void serial_handler(void* frame) {
    unsigned char status = inb(0x3F8 + 5);
    if (!(status & 0x20))
        goto done;

    unsigned int r = write_buffer_read;
    unsigned int w = write_buffer_write;
    if (r == w)
        goto done;

    unsigned char c = write_buffer[r];
    outb(0x3F8, c);

    r = (r + 1) & 4095;
    write_buffer_read = r;

done:
    outb(0x20, 0x20);
}

void serial_init(void) {
    printk("Initializing serial...\n");

    outb(0x3F8 + 1, 0x00);
    outb(0x3F8 + 3, 0x80);
    outb(0x3F8 + 0, 0x03);
    outb(0x3F8 + 1, 0x00);
    outb(0x3F8 + 3, 0x03);
    outb(0x3F8 + 2, 0xC7);
    outb(0x3F8 + 4, 0x0B);

    unsigned int handler = (unsigned int)serial_handler;
    unsigned char* gate = idt + 0x24 * 8;

    gate[0] = handler & 0xFF;
    gate[1] = (handler >> 8) & 0xFF;
    gate[2] = 0x08;
    gate[3] = 0x00;
    gate[4] = 0x00;
    gate[5] = 0x8E;
    gate[6] = (handler >> 16) & 0xFF;
    gate[7] = (handler >> 24) & 0xFF;

    outb(0x3F8 + 1, 0x02);

    unsigned char mask = inb(0x21);
    mask &= 0xEF;
    outb(0x21, mask);
}

void serial_console_write(const char* s) {
    while (*s) {
        unsigned char c = *s++;

        if (c == '\n') {
            serial_console_write("\r");
            c = '\n';
        }

    retry:
        cli();
        unsigned int w = write_buffer_write;
        unsigned int next = (w + 1) & 4095;
        if (next == write_buffer_read) {
            sti();
            pause();
            goto retry;
        }

        write_buffer[w] = c;
        write_buffer_write = next;

        if (w == write_buffer_read) {
            unsigned char status = inb(0x3F8 + 5);
            if (status & 0x20) {
                outb(0x3F8, c);
                unsigned int r = (write_buffer_read + 1) & 4095;
                write_buffer_read = r;
            }
        }

        sti();
    }
}
