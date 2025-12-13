.intel_syntax noprefix
.global isr_handler

isr_handler:
    push ebp
    mov ebp, esp
    pop ebp
    ret
