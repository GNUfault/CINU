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

#include "string.h"

extern unsigned char _binary_font_bin_start[];

volatile unsigned int cursor_x = 0;
volatile unsigned int cursor_y = 0;

#define FB_WIDTH 1024
#define FB_HEIGHT 768
#define BPP 3
#define CHAR_W 8
#define CHAR_H 16
#define COLS (FB_WIDTH / CHAR_W)
#define ROWS (FB_HEIGHT / CHAR_H)

static inline unsigned char *fb_base(void) {
    return (unsigned char *)(unsigned int)(*(unsigned int *)0x5000);
}

void printk(const char *s) {
    if (!s)
        return;

    unsigned char *fb = fb_base();
    unsigned int fb_row_bytes = FB_WIDTH * BPP;
    unsigned int char_row_bytes = CHAR_H * fb_row_bytes;

    while (*s) {
        unsigned char ch = (unsigned char)*s++;

        if (ch == '\n') {
            cursor_x = 0;
            cursor_y++;
            goto check_scroll;
        }

        if (ch < 32 || ch > 126)
            continue;

check_scroll:
        if (cursor_y >= ROWS) {
            unsigned int scroll_bytes = char_row_bytes;
            unsigned int visible_bytes = (ROWS - 1) * scroll_bytes;

            kmemmove(fb, fb + scroll_bytes, visible_bytes);
            kmemset(fb + visible_bytes, 0, scroll_bytes);

            cursor_y = ROWS - 1;
        }

        if (ch == '\n')
            continue;

        const unsigned char *glyph = _binary_font_bin_start + (ch * CHAR_H);

        unsigned char *dst =
            fb + cursor_y * char_row_bytes + cursor_x * CHAR_W * BPP;

        unsigned int row;
        for (row = 0; row < CHAR_H; row++) {
            unsigned char bits = glyph[row];
            unsigned char *p = dst + row * fb_row_bytes;

            unsigned int col;
            for (col = 0; col < CHAR_W; col++) {
                if (bits & 0x80) {
                    p[0] = 0xC0;
                    p[1] = 0xC0;
                    p[2] = 0xC0;
                }
                bits <<= 1;
                p += BPP;
            }
        }

        cursor_x++;
        if (cursor_x >= COLS) {
            cursor_x = 0;
            cursor_y++;
        }
    }
}
