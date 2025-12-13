#ifndef VGA_H
#define VGA_H

void set_cursor(uint16_t position);
void vga_hide_cursor(int hide);
void scroll_screen(void);
void vga_putchar(char c);
void print(const char *str);
void clear_screen(void);

#endif 
