#ifndef IRQ_H
#define IRQ_H

typedef struct {
    unsigned int edi, esi, ebp, esp, ebx, edx, ecx, eax;
    unsigned int int_no, err_code;
    unsigned int eip, cs, eflags, useresp, ss;
} registers;

void irq_handler(registers* regs);

#endif
