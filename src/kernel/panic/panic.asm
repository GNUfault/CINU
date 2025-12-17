[BITS 32]

global panic

extern printk

panic:
    push ebp
    mov ebp, esp

    push panic_msg
    call printk
    add esp, 4

    push dword [ebp + 8]
    call printk
    add esp, 4

    hlt

section .rodata
    panic_msg db "PANIC: ", 0
