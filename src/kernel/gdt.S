.intel_syntax noprefix

.global gdt_init
.global GDT_KERNEL_CODE
.global GDT_KERNEL_DATA
.global GDT_USER_CODE
.global GDT_USER_DATA

.equ GDT_NULL, 0x00
.equ GDT_KERNEL_CODE, 0x08
.equ GDT_KERNEL_DATA, 0x10
.equ GDT_USER_CODE, 0x18
.equ GDT_USER_DATA, 0x20

.section .data
gdt:
    .word 0x0000
    .word 0x0000
    .byte 0x00
    .byte 0x00
    .byte 0x00
    .byte 0x00

    .word 0xFFFF
    .word 0x0000
    .byte 0x00
    .byte 0x9A
    .byte 0xCF
    .byte 0x00

    .word 0xFFFF
    .word 0x0000
    .byte 0x00
    .byte 0x92
    .byte 0xCF
    .byte 0x00

    .word 0xFFFF
    .word 0x0000
    .byte 0x00
    .byte 0xFA
    .byte 0xCF
    .byte 0x00

    .word 0xFFFF
    .word 0x0000
    .byte 0x00
    .byte 0xF2
    .byte 0xCF
    .byte 0x00

gdt_descriptor:
    .word (gdt_end - gdt - 1)
    .long gdt

gdt_end:

.section .text

gdt_init:
    mov eax, offset gdt_descriptor
    lgdt [eax]

    mov ax, GDT_KERNEL_DATA
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp GDT_KERNEL_CODE:flush_cs

flush_cs:
    ret
