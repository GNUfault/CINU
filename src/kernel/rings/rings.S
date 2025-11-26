.intel_syntax noprefix
.global enter_user
.global enter_kernel

USER_STACK_TOP = 0x8FFFC
USER_CODE = 0x80000
USER_DS = 0x23
USER_CS = 0x1B

enter_user:
    cli
    mov ax, USER_DS
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov eax, USER_STACK_TOP
    push USER_DS
    push eax
    pushfd
    push USER_CS
    push USER_CODE
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
