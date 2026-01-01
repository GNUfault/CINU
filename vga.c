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

#define VGA_MEMORY ((uint16_t*)0xB8000)
#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 25

static uint8_t vga_cursor_x = 0;
static uint8_t vga_cursor_y = 0;
static bool vga_scrolling_enabled = true;

static inline uint16_t vga_entry(char c) {
    return (uint16_t)c | (0x07 << 8);
}

void scroll_screen(void) {
    for (uint8_t row = 1; row < SCREEN_HEIGHT; row++) {
        for (uint8_t col = 0; col < SCREEN_WIDTH; col++) {
            VGA_MEMORY[(row - 1) * SCREEN_WIDTH + col] =
                VGA_MEMORY[row * SCREEN_WIDTH + col];
        }
    }

    for (uint8_t col = 0; col < SCREEN_WIDTH; col++) {
        VGA_MEMORY[(SCREEN_HEIGHT - 1) * SCREEN_WIDTH + col] = vga_entry(' ');
    }
}

void vga_putchar(char c) {
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
    while (*str) vga_putchar(*str++);
}
