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

#include "io.h"

// 0xB8000
#define VGA_MEMORY ((unsigned short*)0xB8000)

// Screen dimensions
#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 25
#define SCREEN_SIZE (SCREEN_WIDTH * SCREEN_HEIGHT)

// Cursor position
static unsigned int vga_cursor_x = 0;
static unsigned int vga_cursor_y = 0;

// Enable scrolling
static int vga_scrolling_enabled = 1;

static void set_cursor(unsigned int pos) {
    // Low byte of the cursor index
    outb(0x3D4, 0x0F);
    outb(0x3D5, (unsigned char)(pos & 0xFF));

    // High byte of the cursor index
    outb(0x3D4, 0x0E);
    outb(0x3D5, (unsigned char)((pos >> 8) & 0xFF));
}

// This just sets a VGA entry with a 
// character and default attribute byte 
// (0x07 = Light Grey (Default VGA color))
static inline unsigned short vga_entry(char c) {
    return (unsigned short)c | (0x07u << 8);
}

// Scrolls screen up by one
static void scroll_screen(void) {
    unsigned int row, col;

    // Shift it up by one
    for (row = 1; row < SCREEN_HEIGHT; row++) {
        for (col = 0; col < SCREEN_WIDTH; col++) {
            VGA_MEMORY[(row - 1) * SCREEN_WIDTH + col] =
                VGA_MEMORY[row * SCREEN_WIDTH + col];
        }
    }

    // Clear last row
    for (col = 0; col < SCREEN_WIDTH; col++) {
        VGA_MEMORY[(SCREEN_HEIGHT - 1) * SCREEN_WIDTH + col] = vga_entry(' ');
    }
}

// Puts a single character on the screen
// It handles:
// 1. Newline (\n)
// 2. Backspace (\b)
// 3. Wrapping
// 4. Scrolling (with scroll_screen())
static void putchar(char c) {
    // Newline
    if (c == '\n') {
        vga_cursor_x = 0;
        vga_cursor_y++;
    } else 
        // Backspace
        if (c == '\b') {
            // Move cursor left if we can
            if (vga_cursor_x > 0) {
                vga_cursor_x--;
            } else 
                // If we can't then move to end of the previous line
                if (vga_cursor_y > 0) {
                    vga_cursor_y--;
                     vga_cursor_x = SCREEN_WIDTH - 1;
                }
        // Clear it
        VGA_MEMORY[vga_cursor_y * SCREEN_WIDTH + vga_cursor_x] = vga_entry(' ');
    } else {
        // Print character to screen
        VGA_MEMORY[vga_cursor_y * SCREEN_WIDTH + vga_cursor_x] = vga_entry(c);
        // Move cursor right
        vga_cursor_x++;
    }

    // Wrap to next line if needed
    if (vga_cursor_x >= SCREEN_WIDTH) {
        // Put all the way to the left
        vga_cursor_x = 0;
        // Go to next line
        vga_cursor_y++;
    }

    // Scroll if needed
    if (vga_cursor_y >= SCREEN_HEIGHT) {
        // Check if scrolling is enabled
        if (vga_scrolling_enabled) {
            // Scroll screen
            scroll_screen();
            // Put cursor on last line
            vga_cursor_y = SCREEN_HEIGHT - 1;
        } else {
            // Do not scroll
            vga_cursor_y = SCREEN_HEIGHT - 1;
            vga_cursor_x = 0;
        }
    }

    // Update cursor
    set_cursor(vga_cursor_y * SCREEN_WIDTH + vga_cursor_x);
}

// Prints a null terminated string with putchar()
void printk(const char *str) {
    while (*str) putchar(*str++);
}

// Fills VGA buffer with spaces and put cursor to 0x0
void clear_screen(void) {
    unsigned short *video = (unsigned short *)VGA_MEMORY;
    
    // Set blank to space
    unsigned short blank = (unsigned short)(' ' | (0x07 << 8));

    // Fill screen with blank
    int i;
    for (i = 0; i < SCREEN_SIZE; i++) {
        video[i] = blank;
    }

    // Set cursor to 0x0
    vga_cursor_x = 0;
    vga_cursor_y = 0;
    set_cursor(0);
}
