#ifndef VGA_H
#define VGA_H

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;

#define VGA_MEMORY ((volatile uint16_t *)0xB8000)
#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 25
#define SCREEN_SIZE (SCREEN_WIDTH * SCREEN_HEIGHT)

typedef enum {
    VGA_COLOR_BLACK = 0,
    VGA_COLOR_BLUE = 1,
    VGA_COLOR_GREEN = 2,
    VGA_COLOR_CYAN = 3,
    VGA_COLOR_RED = 4,
    VGA_COLOR_MAGENTA = 5,
    VGA_COLOR_BROWN = 6,
    VGA_COLOR_LIGHT_GREY = 7,
    VGA_COLOR_DARK_GREY = 8,
    VGA_COLOR_LIGHT_BLUE = 9,
    VGA_COLOR_LIGHT_GREEN = 10,
    VGA_COLOR_LIGHT_CYAN = 11,
    VGA_COLOR_LIGHT_RED = 12,
    VGA_COLOR_LIGHT_MAGENTA = 13,
    VGA_COLOR_LIGHT_BROWN = 14,
    VGA_COLOR_WHITE = 15,
} vga_color_t;

#define VGA_COLOR(fg, bg) ((bg << 4) | (fg & 0x0F))

static uint8_t current_fg = VGA_COLOR_LIGHT_GREY;
static uint8_t current_bg = VGA_COLOR_BLACK;

extern uint8_t vga_cursor_x;
extern uint8_t vga_cursor_y;
extern int vga_cursor_hidden;
extern int vga_scrolling_enabled;
extern uint8_t saved_cursor_start;
extern uint8_t saved_cursor_end;

extern void outb(uint16_t port, uint8_t value);
extern uint8_t inb(uint16_t port);

extern uint8_t get_vga_color(void);

void set_cursor(uint16_t position);
void vga_hide_cursor(int hide);
void scroll_screen(void);
void vga_putchar(char c);
void print(const char *str);
void clear_screen(void);

#endif 
