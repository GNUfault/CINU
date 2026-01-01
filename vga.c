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

#include "io.h"

#define VGA_MEMORY ((unsigned short*)0xB8000)
#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 25

static unsigned int vga_cursor_x = 0;
static unsigned int vga_cursor_y = 0;
static int vga_scrolling_enabled = 1;

static void set_cursor(unsigned int pos) {
    outb(0x3D4, 0x0F);
    outb(0x3D5, (unsigned char)(pos & 0xFF));
    outb(0x3D4, 0x0E);
    outb(0x3D5, (unsigned char)((pos >> 8) & 0xFF));
}

static inline unsigned short vga_entry(char c) {
    return (unsigned short)c | (0x07u << 8);
}

static void scroll_screen(void) {
    unsigned int row, col;
    for (row = 1; row < SCREEN_HEIGHT; row++) {
        for (col = 0; col < SCREEN_WIDTH; col++) {
            VGA_MEMORY[(row - 1) * SCREEN_WIDTH + col] =
                VGA_MEMORY[row * SCREEN_WIDTH + col];
        }
    }
    for (col = 0; col < SCREEN_WIDTH; col++) {
        VGA_MEMORY[(SCREEN_HEIGHT - 1) * SCREEN_WIDTH + col] = vga_entry(' ');
    }
}

static void putchar(char c) {
    if (c == '\n') {
        vga_cursor_x = 0;
        vga_cursor_y++;
    } else if (c == '\b') {
        if (vga_cursor_x > 0) {
            vga_cursor_x--;
        } else if (vga_cursor_y > 0) {
            vga_cursor_y--;
            vga_cursor_x = SCREEN_WIDTH - 1;
        }
        VGA_MEMORY[vga_cursor_y * SCREEN_WIDTH + vga_cursor_x] = vga_entry(' ');
    } else {
        VGA_MEMORY[vga_cursor_y * SCREEN_WIDTH + vga_cursor_x] = vga_entry(c);
        vga_cursor_x++;
    }

    if (vga_cursor_x >= SCREEN_WIDTH) {
        vga_cursor_x = 0;
        vga_cursor_y++;
    }

    if (vga_cursor_y >= SCREEN_HEIGHT) {
        if (vga_scrolling_enabled) {
            scroll_screen();
            vga_cursor_y = SCREEN_HEIGHT - 1;
        } else {
            vga_cursor_y = SCREEN_HEIGHT - 1;
            vga_cursor_x = 0;
        }
    }

    set_cursor(vga_cursor_y * SCREEN_WIDTH + vga_cursor_x);
}

void printk(const char *str) {
    while (*str) putchar(*str++);
}

void clear_screen(void) {
    unsigned short blank = (unsigned short)(' ' | (get_vga_color() << 8));
    unsigned short *video = (unsigned short *)VGA_MEMORY;

    int i;
    for (i = 0; i < SCREEN_SIZE; i++) {
        video[i] = blank;
    }

    vga_cursor_x = 0;
    vga_cursor_y = 0;
    set_cursor(0);
}

