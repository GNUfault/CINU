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

#define VESA_WIDTH 1024
#define VESA_HEIGHT 768
#define VESA_BPP 3  // 24-bit color = 3 bytes per pixel
#define VESA_PITCH (VESA_WIDTH * VESA_BPP)
#define FONT_WIDTH 8
#define FONT_HEIGHT 16

static unsigned char *vesa_fb;
extern unsigned char _binary_font_bin_start[];

static unsigned int cursor_x = 0;
static unsigned int cursor_y = 0;
#define PRINTK_FG 0xC0C0C0
#define PRINTK_BG 0x000000

static inline void vga_putpixel(unsigned int x, unsigned int y, unsigned int color) {
    unsigned char *pixel = vesa_fb + (y * VESA_PITCH) + (x * VESA_BPP);
    pixel[0] = color & 0xFF;         // Blue
    pixel[1] = (color >> 8) & 0xFF;  // Green
    pixel[2] = (color >> 16) & 0xFF; // Red
}

// NTSC Color Bars Test Pattern
void test_pattern(void) {
    unsigned int x, y;
    unsigned int bar_width = VESA_WIDTH / 7;
    
    // NTSC Color Bar colors (in RGB format)
    unsigned int colors[7] = {
        0xFFFFFF,  // White
        0xFFFF00,  // Yellow
        0x00FFFF,  // Cyan
        0x00FF00,  // Green
        0xFF00FF,  // Magenta
        0xFF0000,  // Red
        0x0000FF   // Blue
    };
    
    // Draw the main color bars (top 2/3 of screen)
    unsigned int main_height = (VESA_HEIGHT * 2) / 3;
    for(y = 0; y < main_height; y++) {
        for(x = 0; x < VESA_WIDTH; x++) {
            unsigned int bar = x / bar_width;
            if(bar > 6) bar = 6;
            vga_putpixel(x, y, colors[bar]);
        }
    }
    
    // Draw the bottom section with smaller blocks
    unsigned int bottom_start = main_height;
    unsigned int bottom_height = VESA_HEIGHT - main_height;
    unsigned int block_height = bottom_height / 3;
    
    // Middle section: Reverse order bars
    for(y = bottom_start; y < bottom_start + block_height; y++) {
        for(x = 0; x < VESA_WIDTH; x++) {
            unsigned int bar = x / bar_width;
            if(bar > 6) bar = 6;
            vga_putpixel(x, y, colors[6 - bar]);
        }
    }
    
    // Bottom left: Black to white gradient
    unsigned int gradient_start = bottom_start + block_height;
    for(y = gradient_start; y < gradient_start + block_height; y++) {
        for(x = 0; x < VESA_WIDTH / 2; x++) {
            unsigned int shade = (x * 255) / (VESA_WIDTH / 2);
            unsigned int color = (shade << 16) | (shade << 8) | shade;
            vga_putpixel(x, y, color);
        }
    }
    
    // Bottom right: Black
    for(y = gradient_start; y < gradient_start + block_height; y++) {
        for(x = VESA_WIDTH / 2; x < VESA_WIDTH; x++) {
            vga_putpixel(x, y, 0x000000);
        }
    }
    
    // Very bottom: PLUGE pattern
    unsigned int pluge_start = gradient_start + block_height;
    unsigned int pluge_width = VESA_WIDTH / 7;
    unsigned int pluge_colors[7] = {
        0x000000,  // Black
        0x050505,  // Below black (<3.5%)
        0x000000,  // Black
        0x090909,  // 3.5% white
        0x000000,  // Black  
        0x0D0D0D,  // Above black (>3.5%)
        0x000000   // Black
    };
    
    for(y = pluge_start; y < VESA_HEIGHT; y++) {
        for(x = 0; x < VESA_WIDTH; x++) {
            unsigned int section = x / pluge_width;
            if(section > 6) section = 6;
            vga_putpixel(x, y, pluge_colors[section]);
        }
    }
}

static void scroll_up() {
    unsigned int row_bytes = VESA_PITCH * FONT_HEIGHT;
    unsigned int total_bytes = VESA_PITCH * VESA_HEIGHT;
    
    // Move all rows up by FONT_HEIGHT pixels
    for(unsigned int i = 0; i < total_bytes - row_bytes; i++) {
        vesa_fb[i] = vesa_fb[i + row_bytes];
    }
    
    // Clear the bottom FONT_HEIGHT rows
    for(unsigned int i = total_bytes - row_bytes; i < total_bytes; i++) {
        vesa_fb[i] = 0;
    }
    
    cursor_y -= FONT_HEIGHT;
}

static void vga_draw_char_internal(unsigned int x, unsigned int y, char c, unsigned int fg, unsigned int bg) {
    unsigned char *glyph = _binary_font_bin_start + ((unsigned char)c * FONT_HEIGHT);
    
    for(unsigned int row = 0; row < FONT_HEIGHT; row++) {
        unsigned char bits = glyph[row];
        for(unsigned int col = 0; col < FONT_WIDTH; col++) {
            if(bits & (0x80 >> col)) {
                vga_putpixel(x + col, y + row, fg);
            } else {
                vga_putpixel(x + col, y + row, bg);
            }
        }
    }
}

void printk(const char *s) {
    while(*s) {
        if(*s == '\n') {
            cursor_x = 0;
            cursor_y += FONT_HEIGHT;
            if(cursor_y >= VESA_HEIGHT - FONT_HEIGHT) {
                scroll_up();
            }
        } else {
            vga_draw_char_internal(cursor_x, cursor_y, *s, PRINTK_FG, PRINTK_BG);
            cursor_x += FONT_WIDTH;
            if(cursor_x >= VESA_WIDTH) {
                cursor_x = 0;
                cursor_y += FONT_HEIGHT;
                if(cursor_y >= VESA_HEIGHT - FONT_HEIGHT) {
                    scroll_up();
                }
            }
        }
        s++;
    }
}

void vga_init(void) {
    // Read the framebuffer address that the bootloader stored at 0x5000
    vesa_fb = (unsigned char *)(*((unsigned int *)0x5000));
    
    // Test: Fill screen with red
    for(unsigned int y = 0; y < VESA_HEIGHT; y++) {
        for(unsigned int x = 0; x < VESA_WIDTH; x++) {
            vga_putpixel(x, y, 0xFF0000);
        }
    }
}
