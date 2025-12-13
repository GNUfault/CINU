#ifndef GDT_H
#define GDT_H

extern void gdt_flush(unsigned int gdt_ptr_address);
extern void tss_flush(unsigned short selector);

void gdt_set_entry(int index, unsigned int base, unsigned int limit, unsigned char access, unsigned char granularity);
void gdt_install(void);

void write_tss(int index, unsigned short ss0, unsigned int esp0);
void tss_install(void);

#endif
