/*
 * CINUX
 * Copyright (C) 2025 Connor Thomson
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License
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
#define FONT_WIDTH 8
#define FONT_HEIGHT 16
#define COLOR_LIGHT_GREY 0xC0C0C0

static unsigned int *framebuffer = 0;
static unsigned char font_data[256 * FONT_HEIGHT];
static int cursor_x = 0;
static int cursor_y = 0;

void load_font(void) {
    extern unsigned char _binary_font_bin_start[];
    unsigned char *font_ptr = _binary_font_bin_start;
    
    for (int i = 0; i < 256 * FONT_HEIGHT; i++) {
        font_data[i] = font_ptr[i];
    }
}

static void draw_char(char c, int x, int y, unsigned int color) {
    unsigned char *glyph = &font_data[(unsigned char)c * FONT_HEIGHT];
    
    for (int row = 0; row < FONT_HEIGHT; row++) {
        unsigned char line = glyph[row];
        for (int col = 0; col < FONT_WIDTH; col++) {
            if (line & (0x80 >> col)) {
                int px = x + col;
                int py = y + row;
                if (px < SCREEN_WIDTH && py < SCREEN_HEIGHT) {
                    framebuffer[py * SCREEN_WIDTH + px] = color;
                }
            }
        }
    }
}

static void scroll_screen(void) {
    for (int y = FONT_HEIGHT; y < SCREEN_HEIGHT; y++) {
        for (int x = 0; x < SCREEN_WIDTH; x++) {
            framebuffer[(y - FONT_HEIGHT) * SCREEN_WIDTH + x] = 
                framebuffer[y * SCREEN_WIDTH + x];
        }
    }
    
    for (int y = SCREEN_HEIGHT - FONT_HEIGHT; y < SCREEN_HEIGHT; y++) {
        for (int x = 0; x < SCREEN_WIDTH; x++) {
            framebuffer[y * SCREEN_WIDTH + x] = 0;
        }
    }
}

static void putchar_internal(char c) {
    if (c == '\n') {
        cursor_x = 0;
        cursor_y += FONT_HEIGHT;
    } else if (c == '\r') {
        cursor_x = 0;
    } else if (c == '\t') {
        cursor_x = (cursor_x + FONT_WIDTH * 4) & ~(FONT_WIDTH * 4 - 1);
    } else if (c == '\b') {
        if (cursor_x >= FONT_WIDTH) {
            cursor_x -= FONT_WIDTH;
        }
    } else {
        draw_char(c, cursor_x, cursor_y, COLOR_LIGHT_GREY);
        cursor_x += FONT_WIDTH;
    }
    
    if (cursor_x >= SCREEN_WIDTH) {
        cursor_x = 0;
        cursor_y += FONT_HEIGHT;
    }
    
    if (cursor_y >= SCREEN_HEIGHT) {
        scroll_screen();
        cursor_y = SCREEN_HEIGHT - FONT_HEIGHT;
    }
}

static void print_int(int num) {
    if (num == 0) {
        putchar_internal('0');
        return;
    }
    
    char buffer[12];
    int i = 0;
    int is_negative = 0;
    
    if (num < 0) {
        is_negative = 1;
        num = -num;
    }
    
    while (num > 0) {
        buffer[i++] = '0' + (num % 10);
        num /= 10;
    }
    
    if (is_negative) {
        putchar_internal('-');
    }
    
    while (i > 0) {
        putchar_internal(buffer[--i]);
    }
}

static void print_hex(unsigned int num) {
    const char *hex_digits = "0123456789ABCDEF";
    putchar_internal('0');
    putchar_internal('x');
    
    for (int i = 28; i >= 0; i -= 4) {
        putchar_internal(hex_digits[(num >> i) & 0xF]);
    }
}

static inline void va_start_impl(char **ap, void *last) {
    *ap = (char *)last + ((sizeof(void *) + 3) & ~3);
}

static inline void va_end_impl(char **ap) {
    *ap = (void *)0;
}

static inline void *va_arg_impl(char **ap, int size) {
    void *result = (void *)*ap;
    *ap += (size + 3) & ~3;
    return result;
}

void printk(const char *format, ...) {
    char *args;
    va_start_impl(&args, (void *)&format);
    
    while (*format) {
        if (*format == '%') {
            format++;
            switch (*format) {
                case 'd':
                case 'i': {
                    int *p = va_arg_impl(&args, sizeof(int));
                    print_int(*p);
                    break;
                }
                case 'x':
                case 'X': {
                    unsigned int *p = va_arg_impl(&args, sizeof(unsigned int));
                    print_hex(*p);
                    break;
                }
                case 's': {
                    const char **p = va_arg_impl(&args, sizeof(const char *));
                    const char *str = *p;
                    while (*str) {
                        putchar_internal(*str++);
                    }
                    break;
                }
                case 'c': {
                    int *p = va_arg_impl(&args, sizeof(int));
                    putchar_internal((char)*p);
                    break;
                }
                case '%':
                    putchar_internal('%');
                    break;
                default:
                    putchar_internal('%');
                    putchar_internal(*format);
                    break;
            }
        } else {
            putchar_internal(*format);
        }
        format++;
    }
    
    va_end_impl(&args);
}

void vga_init(unsigned int *fb_address) {
    framebuffer = fb_address;
    cursor_x = 0;
    cursor_y = 0;
    
    for (int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {
        framebuffer[i] = 0;
    }
    
    load_font();
}
