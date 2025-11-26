.intel_syntax noprefix

.section .text
.global inb
.global inw
.global inl
.global outb
.global outw
.global outl

inb:
    mov dx, [esp+4]
    in al, dx
    movzx eax, al
    ret

inw:
    mov dx, [esp+4]
    in ax, dx
    movzx eax, ax
    ret

inl:
    mov dx, [esp+4]
    in eax, dx
    ret

outb:
    mov dx, [esp+4]
    mov al, [esp+8]
    out dx, al
    ret

outw:
    mov dx, [esp+4]
    mov ax, [esp+8]
    out dx, ax
    ret

outl:
    mov dx, [esp+4]
    mov eax, [esp+8]
    out dx, eax
    ret
