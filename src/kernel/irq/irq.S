.intel_syntax noprefix

.global irq_handler

irq_handler:
    push ebp
    mov ebp, esp
    mov esp, ebp
    pop ebp
    ret
