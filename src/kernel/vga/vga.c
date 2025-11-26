#include <stdint.h>
#include "io.h"
#include "vga.h"

uint8_t vga_cursor_x = 0;
uint8_t vga_cursor_y = 0;
int vga_scrolling_enabled = 1;

uint8_t get_vga_color(void) {
    return VGA_COLOR(current_fg, current_bg);
}

void update_cursor(void) {
    uint16_t position = vga_cursor_y * SCREEN_WIDTH + vga_cursor_x;
    outb(0x3D4, 0x0F);
    outb(0x3D5, position & 0xFF);
    outb(0x3D4, 0x0E);
    outb(0x3D5, (position >> 8) & 0xFF);
}

void scroll_screen(void) {
    for (uint8_t row = 1; row < SCREEN_HEIGHT; row++) {
        for (uint8_t col = 0; col < SCREEN_WIDTH; col++) {
            VGA_MEMORY[(row - 1) * SCREEN_WIDTH + col] =
                VGA_MEMORY[row * SCREEN_WIDTH + col];
        }
    }
    uint8_t color_byte = get_vga_color();
    for (uint8_t col = 0; col < SCREEN_WIDTH; col++) {
        VGA_MEMORY[(SCREEN_HEIGHT - 1) * SCREEN_WIDTH + col] =
            ' ' | (color_byte << 8);
    }
}

void vga_putchar(char c) {
    uint8_t color_byte = get_vga_color();

    if (c == '\n') {
        vga_cursor_x = 0;
        vga_cursor_y++;
    } else if (c == '\r') {
        vga_cursor_x = 0;
    } else if (c == '\b') {
        if (vga_cursor_x > 0) {
            vga_cursor_x--;
        } else if (vga_cursor_y > 0) {
            vga_cursor_y--;
            vga_cursor_x = SCREEN_WIDTH - 1;
        }
        VGA_MEMORY[vga_cursor_y * SCREEN_WIDTH + vga_cursor_x] = ' ' | (color_byte << 8);
    } else if (c == '\t') {
        vga_cursor_x = (vga_cursor_x + 8) & ~7;
        if (vga_cursor_x >= SCREEN_WIDTH) {
            vga_cursor_x = 0;
            vga_cursor_y++;
        }
    } else {
        VGA_MEMORY[vga_cursor_y * SCREEN_WIDTH + vga_cursor_x] = c | (color_byte << 8);
        vga_cursor_x++;
        
        if (vga_cursor_x >= SCREEN_WIDTH) {
            vga_cursor_x = 0;
            vga_cursor_y++;
        }
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
    
    update_cursor();
}

void print(const char *str) {
    while (*str) vga_putchar(*str++);
}

void clear_screen(void) {
    uint16_t blank = ' ' | (get_vga_color() << 8);
    uint16_t *video = (uint16_t *)VGA_MEMORY;

    for (int i = 0; i < SCREEN_SIZE; i++) {
        video[i] = blank;
    }

    vga_cursor_x = 0;
    vga_cursor_y = 0;
    update_cursor();
}
