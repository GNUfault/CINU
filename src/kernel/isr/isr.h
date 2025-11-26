#ifndef ISR_H
#define ISR_H

typedef struct {
    unsigned int ds;
    unsigned int edi, esi, ebp, esp_dummy, ebx, edx, ecx, eax;
    unsigned int int_no, err_code;
    unsigned int eip, cs, eflags, useresp, ss;
} registers;

void isr_handler(registers* regs);

#endif
