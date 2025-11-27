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

struct tss_entry {
    unsigned int prev_tss;
    unsigned int esp0;
    unsigned int ss0;
    unsigned int esp1;
    unsigned int ss1;
    unsigned int esp2;
    unsigned int ss2;
    unsigned int cr3;
    unsigned int eip;
    unsigned int eflags;
    unsigned int eax;
    unsigned int ecx;
    unsigned int edx;
    unsigned int ebx;
    unsigned int esp;
    unsigned int ebp;
    unsigned int esi;
    unsigned int edi;
    unsigned int es;
    unsigned int cs;
    unsigned int ss;
    unsigned int ds;
    unsigned int fs;
    unsigned int gs;
    unsigned int ldt;
    unsigned short trap;
    unsigned short iomap_base;
};

extern void gdt_flush(unsigned int gdt_ptr_address);
extern void tss_flush(unsigned short selector);

void gdt_set_entry(int index, unsigned int base, unsigned int limit, unsigned char access, unsigned char granularity);
void gdt_install(void);

void write_tss(int index, unsigned short ss0, unsigned int esp0);
void tss_install(void);

#endif
