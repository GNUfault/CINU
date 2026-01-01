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

#include "serial.h"

#define VGA_WIDTH 128
#define VGA_HEIGHT 48
#define VGA_MEM ((unsigned char*)0x5000)
#define FONT_HEIGHT 16
#define FONT_WIDTH 8

unsigned int cursor_x = 0;
unsigned int cursor_y = 0;

extern unsigned char font[];

static void scroll_screen(void) {
    int i;
    unsigned char* vga = VGA_MEM;
    unsigned int* src = (unsigned int*)(vga + FONT_HEIGHT * VGA_WIDTH * 3);
    unsigned int* dst = (unsigned int*)vga;
    for (i = 0; i < (VGA_HEIGHT - 1) * FONT_HEIGHT * VGA_WIDTH * 3 / 4; i++) {
        dst[i] = src[i];
    }
    unsigned int* clear = (unsigned int*)(vga + (VGA_HEIGHT - 1) * FONT_HEIGHT * VGA_WIDTH * 3);
    for (i = 0; i < FONT_HEIGHT * VGA_WIDTH * 3 / 4; i++) {
        clear[i] = 0;
    }
    cursor_y--;
}

void printk(const char* str) {
    serial_console_write(str);
    unsigned char* vga = VGA_MEM;
    while (*str) {
        char c = *str++;
        if (c == '\n') {
            cursor_x = 0;
            cursor_y++;
            if (cursor_y >= VGA_HEIGHT) scroll_screen();
            continue;
        }
        if (c < 32 || c > 126) continue;
        if (cursor_y >= VGA_HEIGHT) scroll_screen();
        unsigned char* glyph = &font[c * FONT_HEIGHT];
        int row, col;
        for (row = 0; row < FONT_HEIGHT; row++) {
            unsigned char bits = glyph[row];
            unsigned int* pixel = (unsigned int*)(vga + (cursor_y * FONT_HEIGHT + row) * VGA_WIDTH * 3 + cursor_x * 3);
            for (col = 0; col < FONT_WIDTH; col++) {
                if (bits & 0x80) {
                    *pixel = 0xC0C0C0;
                }
                pixel = (unsigned int*)((unsigned char*)pixel + 3);
                bits <<= 1;
            }
        }
        cursor_x++;
        if (cursor_x >= VGA_WIDTH) {
            cursor_x = 0;
            cursor_y++;
        }
    }
}
