global isr128
extern syscall_handler

isr128:
    pusha
    push ds
    push es
    push fs
    push gs

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call syscall_handler

    pop gs
    pop fs
    pop es
    pop ds
    popa
    iretd
