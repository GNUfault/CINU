.intel_syntax noprefix
.global enter_user
.global enter_kernel
.extern init

enter_user:
    mov ax, 0x23
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov eax, esp
    push 0x23
    push eax
    pushf
    push 0x1B
    push init
    iret

enter_kernel:
    cli
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov esp, 0x90000
    sti
    ret
