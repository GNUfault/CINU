.intel_syntax noprefix
.global syscall_handler

syscall_handler:
    push ebp
    mov ebp, esp
    mov esp, ebp
    pop ebp
    ret
