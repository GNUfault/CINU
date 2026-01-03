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
#define VESA_PITCH (1024*4)
#define FONT_WIDTH 8
#define FONT_HEIGHT 16

static unsigned int *vesa_fb;
extern unsigned char _binary_font_bin_start[];

static inline void vga_putpixel(unsigned int x, unsigned int y, unsigned int color) {
    vesa_fb[y*(VESA_PITCH>>2)+x] = color;
}

static void scroll_up() {
    unsigned int x,y;
    for(y=0;y<VESA_HEIGHT-FONT_HEIGHT;y++) {
        for(x=0;x<VESA_WIDTH;x++) {
            unsigned int *fb=(unsigned int *)((char *)vesa_fb + (y*VESA_WIDTH+x)*4);
            unsigned int *src=(unsigned int *)((char *)vesa_fb + ((y+FONT_HEIGHT)*VESA_WIDTH+x)*4);
            *fb = *src;
        }
    }
    for(y=VESA_HEIGHT-FONT_HEIGHT;y<VESA_HEIGHT;y++) {
        for(x=0;x<VESA_WIDTH;x++) {
            unsigned int *fb=(unsigned int *)((char *)vesa_fb + (y*VESA_WIDTH+x)*4);
            *fb=0x000000;
        }
    }
}

static void vga_draw_char_internal(unsigned int x, unsigned int y, char c, unsigned int fg, unsigned int bg) {
    unsigned int row=0;
    unsigned char *glyph=_binary_font_bin_start + ((unsigned char)c*FONT_HEIGHT);
    while(row<FONT_HEIGHT) {
        unsigned char bits=glyph[row];
        unsigned int col=0;
        while(col<FONT_WIDTH) {
            if(bits & (0x80>>col)) vga_putpixel(x+col,y+row,fg);
            else vga_putpixel(x+col,y+row,bg);
            col++;
        }
        row++;
    }
}

static unsigned int cursor_x=0;
static unsigned int cursor_y=0;
#define PRINTK_FG 0xC0C0C0
#define PRINTK_BG 0x000000

void printk(const char *s) {
    while(*s) {
        if(*s=='\n') {
            cursor_x=0;
            cursor_y+=FONT_HEIGHT;
            if(cursor_y+FONT_HEIGHT>VESA_HEIGHT) scroll_up();
        } else {
            vga_draw_char_internal(cursor_x,cursor_y,*s,PRINTK_FG,PRINTK_BG);
            cursor_x+=FONT_WIDTH;
            if(cursor_x+FONT_WIDTH>VESA_WIDTH) {
                cursor_x=0;
                cursor_y+=FONT_HEIGHT;
                if(cursor_y+FONT_HEIGHT>VESA_HEIGHT) scroll_up();
            }
        }
        s++;
    }
}

void vga_init(void) {
    vesa_fb = (unsigned int *)(*((unsigned int *)0x5000));
}
