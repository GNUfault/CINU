#ifndef GDT_H
#define GDT_H

struct gdt_entry {
    unsigned short limit_low;
    unsigned short base_low;
    unsigned char base_middle;
    unsigned char access;
    unsigned char granularity;
    unsigned char base_high;
};

struct gdt_ptr {
    unsigned short limit;
    unsigned int base;
};

extern void gdt_flush(unsigned int gdt_ptr_address);

void gdt_set_entry(int index, unsigned int base, unsigned int limit, unsigned char access, unsigned char granularity);
void gdt_install(void);

#endif
