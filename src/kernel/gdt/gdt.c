#include "gdt.h"

struct gdt_entry gdt[6];
struct gdt_ptr gp;
struct tss_entry tss;

unsigned char kernel_stack[4096];

void gdt_set_entry(int index, unsigned int base, unsigned int limit, unsigned char access, unsigned char granularity) {
    gdt[index].base_low = base & 0xFFFF;
    gdt[index].base_middle = (base >> 16) & 0xFF;
    gdt[index].base_high = (base >> 24) & 0xFF;
    gdt[index].limit_low = limit & 0xFFFF;
    gdt[index].granularity = ((limit >> 16) & 0x0F) | (granularity & 0xF0);
    gdt[index].access = access;
}

void gdt_install(void) {
    gp.limit = sizeof(gdt) - 1;
    gp.base  = (unsigned int)&gdt;

    gdt_set_entry(0, 0, 0, 0, 0);
    gdt_set_entry(1, 0, 0xFFFFFFFF, 0x9A, 0xCF);
    gdt_set_entry(2, 0, 0xFFFFFFFF, 0x92, 0xCF);
    gdt_set_entry(3, 0, 0xFFFFFFFF, 0xFA, 0xCF);
    gdt_set_entry(4, 0, 0xFFFFFFFF, 0xF2, 0xCF);
    gdt_flush((unsigned int)&gp);
}

void write_tss(int index, unsigned short ss0, unsigned int esp0) {
    unsigned int base = (unsigned int)&tss;
    unsigned int limit = sizeof(tss) - 1;

    gdt_set_entry(index, base, limit, 0x89, 0x40);

    unsigned char *p = (unsigned char *)&tss;
    for (unsigned int i = 0; i < sizeof(tss); i++) {
        p[i] = 0;
    }

    tss.ss0 = ss0;
    tss.esp0 = esp0;
    tss.iomap_base = sizeof(tss);
}

void tss_install(void) {
    unsigned short kernel_ss = 0x10;
    unsigned int kernel_esp = (unsigned int)&kernel_stack[4096];

    write_tss(5, kernel_ss, kernel_esp);
    tss_flush(5 << 3);
}
