.intel_syntax noprefix

.global jump_usermode

.extern init

jump_usermode:
    mov ax, (4 * 8) | 3
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov eax, esp
    push (4 * 8) | 3
    push eax
    pushf
    push (3 * 8) | 3
    push offset init
    iret
