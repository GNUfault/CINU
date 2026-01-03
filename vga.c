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

#define VESA_FB_ADDR_PTR 0x5000
#define VESA_WIDTH  1024
#define VESA_HEIGHT 768
#define VESA_PITCH  (1024 * 4) /* bytes per row */
#define FONT_WIDTH  8
#define FONT_HEIGHT 16

static unsigned int *vesa_fb = 0;
extern unsigned char _binary_font_bin_start[];

void store_fb_address(void) {
    unsigned int *ptr = (unsigned int *)VESA_FB_ADDR_PTR;
    vesa_fb = (unsigned int *)(*ptr);
}

static inline void vga_putpixel(unsigned int x, unsigned int y, unsigned int color ) {
    vesa_fb[y * (VESA_PITCH >> 2) + x] = color;
}

void vga_clear(unsigned int color) {
    unsigned int i = 0;
    unsigned int pixels = VESA_WIDTH * VESA_HEIGHT;

    while (i < pixels) {
        vesa_fb[i] = color;
        i++;
    }
}

void vga_draw_char(unsigned int x, unsigned int y, char c, unsigned int fg, unsigned int bg) {
    unsigned int row = 0;
    unsigned char *glyph =
        _binary_font_bin_start + ((unsigned char)c * FONT_HEIGHT);

    while (row < FONT_HEIGHT) {
        unsigned char bits = glyph[row];
        unsigned int col = 0;

        while (col < FONT_WIDTH) {
            if (bits & (0x80 >> col))
                vga_putpixel(x + col, y + row, fg);
            else
                vga_putpixel(x + col, y + row, bg);
            col++;
        }
        row++;
    }
}

void vga_draw_string(unsigned int x, unsigned int y, const char *s, unsigned int fg, unsigned int bg) {
    unsigned int cx = x;

    while (*s) {
        if (*s == '\n') {
            cx = x;
            y += FONT_HEIGHT;
        } else {
            vga_draw_char(cx, y, *s, fg, bg);
            cx += FONT_WIDTH;
        }
        s++;
    }
}
