/*
 * CINUX
 * Copyright (C) 2025 Connor Thomson
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#define SCREEN_WIDTH 1024
#define SCREEN_HEIGHT 768
#define CHAR_WIDTH 8
#define CHAR_HEIGHT 16
#define BYTES_PER_PIXEL 3
#define CHARS_PER_LINE 128
#define LINES_PER_SCREEN 48

unsigned int cursor_x = 0;
unsigned int cursor_y = 0;

extern unsigned char _binary_font_bin_start[];

static void scroll_screen(void) {
    unsigned char *fb = *(unsigned char **)0x5000;
    unsigned int line_size = SCREEN_WIDTH * CHAR_HEIGHT * BYTES_PER_PIXEL;
    unsigned int total_size = line_size * (LINES_PER_SCREEN - 1);
    
    unsigned char *src = fb + line_size;
    unsigned char *dst = fb;
    
    for (unsigned int i = 0; i < total_size; i++) {
        dst[i] = src[i];
    }
    
    dst = fb + line_size * (LINES_PER_SCREEN - 1);
    for (unsigned int i = 0; i < line_size; i++) {
        dst[i] = 0;
    }
    
    cursor_y--;
}

static void draw_char(unsigned char c) {
    if (cursor_y >= LINES_PER_SCREEN) {
        scroll_screen();
    }
    
    unsigned char *fb = *(unsigned char **)0x5000;
    unsigned char *glyph = &_binary_font_bin_start[c * CHAR_HEIGHT];
    
    unsigned int y_offset = cursor_y * CHAR_HEIGHT * SCREEN_WIDTH * BYTES_PER_PIXEL;
    unsigned int x_offset = cursor_x * CHAR_WIDTH * BYTES_PER_PIXEL;
    unsigned char *dest = fb + y_offset + x_offset;
    
    for (int row = 0; row < CHAR_HEIGHT; row++) {
        unsigned char bits = glyph[row];
        
        for (int col = 0; col < CHAR_WIDTH; col++) {
            if (bits & 0x80) {
                dest[0] = 0xC0;
                dest[1] = 0xC0;
                dest[2] = 0xC0;
            }
            bits <<= 1;
            dest += BYTES_PER_PIXEL;
        }
        
        dest += SCREEN_WIDTH * BYTES_PER_PIXEL - CHAR_WIDTH * BYTES_PER_PIXEL;
    }
    
    cursor_x++;
    if (cursor_x >= CHARS_PER_LINE) {
        cursor_x = 0;
        cursor_y++;
    }
}

void printk(const char *str) {
     while (*str) {
        unsigned char c = *str++;
        
        if (c == '\n') {
            cursor_x = 0;
            cursor_y++;
        } else if (c >= 32 && c <= 126) {
            draw_char(c);
        }
    }
}
