[BITS 16]

STACK_TOP equ 0x7C00
LOAD_ADDR equ 0x9000
LOAD_SEGMENTS equ 0x900
SECT_SIZE equ 512

start:
    cli
    xor cx, cx
    mov ss, cx
    mov sp, STACK_TOP
    mov ds, cx

    mov ax, LOAD_SEGMENTS
    mov es, ax
    xor bx, bx
    mov ah, 0x02
    mov al, 64
    mov cx, 0x0002
    xor dh, dh
    int 0x13

    in al, 0x92
    or al, 2
    out 0x92, al

    cli
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:prot32

[BITS 32]
prot32:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    jmp LOAD_ADDR

[BITS 16]

gdt_start:
    dq 0

    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

times 510-($-$$) db 0
dw 0xAA55
