.intel_syntax noprefix

.global load_user

load_user:
    pushad
    mov edi, 0x00080000
    mov ebx, 36
    mov ecx, 32

.next_sector:
    call busy_clear
    mov dx, 0x1F2
    mov al, 1
    out dx, al
    inc dx
    mov eax, ebx
    out dx, al
    inc dx
    shr eax, 8
    out dx, al
    inc dx
    shr eax, 8
    out dx, al
    inc dx
    shr eax, 8
    and al, 0x0F
    or al, 0xE0
    out dx, al
    mov dx, 0x1F7
    mov al, 0x20
    out dx, al
    call wait_drq
    mov dx, 0x1F0
    mov esi, 256

.read:
    in ax, dx
    mov [edi], ax
    add edi, 2
    dec esi
    jnz .read

    inc ebx
    dec ecx
    jnz .next_sector

    popad
    ret

busy_clear:
    mov dx, 0x1F7
.busy:
    in al, dx
    test al, 0x80
    jnz .busy
    ret

wait_drq:
    mov dx, 0x1F7
.drq:
    in al, dx
    test al, 0x08
    jz .drq
    ret
