#ifndef VGA_H
#define VGA_H

void printk_init(unsigned int *fb_address);
void printk(const char *format, ...);

#endif
