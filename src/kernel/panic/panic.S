.intel_syntax noprefix
.global panic

panic:
    push ebp
    mov ebp, esp

    push offset panic_msg
    call printk
    add esp, 4

    push dword ptr [ebp + 8]
    call printk
    add esp, 4

    pop ebp

.section .rodata
panic_msg:
    .asciz "PANIC: "
