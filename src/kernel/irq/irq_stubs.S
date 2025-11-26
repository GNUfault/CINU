.intel_syntax noprefix

.global common_irq
.extern irq_handler

common_irq:
    pusha
    mov eax, esp
    push eax
    call irq_handler
    add esp, 4
    popa
    add esp, 8
    iretd
