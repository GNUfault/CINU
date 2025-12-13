#ifndef VGA_H
#define VGA_H

unsigned char get_vga_color(void);
void set_cursor(unsigned short position);
void vga_hide_cursor(unsigned int hide);
void scroll_screen(void);
void vga_putchar(char c);
void print(const char* str);
void clear_screen(void);

#endif
