.intel_syntax noprefix
.code16

.equ STACK_TOP, 0x7C00
.equ SELF_LOAD, 0x7C00
.equ ELF_HDR_LOAD, 0x7E00

.equ SECT_SIZE, 512
.equ SECT_SHIFT, 9
.equ GEOM_SECTORS, 18
.equ GEOM_CYLINDERS, 80
.equ GEOM_HEADS, 2

.equ elf_phoff, 0x1C
.equ elf_phnum, 0x2C
.equ elf_entry, 0x18

.equ elf_seg_type, 0x00
.equ elf_seg_file_offset, 0x04
.equ elf_seg_paddr, 0x0C
.equ elf_seg_filesz, 0x10
.equ elf_seg_memsz, 0x14
.equ elf_seg_struct_size, 0x20

.equ gdt_fl_pglimit, 0x80
.equ gdt_fl_32b, 0x40

.equ gdt_a_present, 0x80
.equ gdt_a_dpl0, 0x00
.equ gdt_a_nosys, 0x10
.equ gdt_a_exec, 0x08
.equ gdt_a_conforming, 0x04
.equ gdt_a_grow_down, 0x04
.equ gdt_a_rw, 0x2
.equ gdt_a_accessed, 0x1

.section .text
.global start
start:
cli
jmp 0:start2
start2:
xor cx, cx
mov ss, cx
mov sp, STACK_TOP
mov ds, cx

mov ax, 0xB800
mov es, ax
xor di, di
mov ah, 0x0F

mov al, ' '
mov cx, 2000
.clear_loop:
stosw
loop .clear_loop
mov ah, 0x02
xor bh, bh
xor dh, dh
xor dl, dl
int 0x10

mov si, drives

scan_floppy:
    lodsb
    test al, al
    jz no_drives
    mov dl, al

    mov ax, 0x0201
    mov cx, 0x0002
    xor dx, dx
    mov bx, ELF_HDR_LOAD/16
    mov es, bx
    xor bx, bx
    int 0x13
    jc scan_floppy

    jmp load_init

load_init:
    mov ax, ELF_HDR_LOAD/16
    mov ds, ax
    mov si, [elf_phoff]
    mov cl, [elf_phnum]

load_segment:
    push cx
    mov eax, [si + elf_seg_type]
    dec eax
    jnz skip_seg

    mov ebx, [si + elf_seg_paddr]
    shr ebx, 4
    mov es, bx

    mov eax, [si + elf_seg_file_offset]
    shr eax, SECT_SHIFT
    inc ax

    push dx
    xor dx, dx
    mov bx, GEOM_SECTORS
    div bx
    mov cl, dl
    inc cl
    mov bl, GEOM_HEADS
    div bl
    pop dx
    mov dh, ah
    mov ch, al

    xor ebx, ebx
    mov bx, SECT_SIZE - 1
    mov eax, [si + elf_seg_filesz]
    add eax, ebx
    shr eax, SECT_SHIFT

    mov ah, 0x02
    xor bx, bx
    int 0x13
    jc load_seg_fail

skip_seg:
    pop cx
    add si, elf_seg_struct_size
    loop short load_segment

    mov esi, [elf_entry]

    .equ gdtp, 0
    .equ gdt, 8
    cld
    mov ax, ds
    mov es, ax
    xor di, di

    xor eax, eax
    mov al, 3*8 - 1
    stosw
    mov ax, ELF_HDR_LOAD + gdt
    stosd
    stosw

    xor eax, eax
    stosd
    stosd
    lea bx, [gdt_code]
    mov eax, cs:[bx]
    mov edx, cs:[bx+4]
    stosd
    xchg eax, edx
    stosd
    xchg eax, edx
    stosd
    xchg eax, edx
    stosd
    mov al, gdt_a_present | gdt_a_nosys | gdt_a_dpl0 | gdt_a_rw | gdt_a_accessed
    mov ds:[gdt + 8*2 + 5], al
  
    mov ax, 0x4F02
    mov bx, 0x4118
    int 0x10
  
    in al, 0x92
    or al, 2
    out 0x92, al

    lgdt [gdtp]
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 8:prot32

.code32
prot32:
    xor eax, eax
    mov al, 16
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp esi

.code16

print:
    cld
    mov ah, 0x0E
    xor bx, bx
.loop:
    lodsb
    test al, al
    jz .ret
    int 0x10
    jmp .loop
.ret:
    ret

no_drives:
    mov ds, bx
    mov si, offset msg_no_drives
    call print
    cli
    hlt

drives:
    .byte 0x00
    .byte 0x01
    .byte 0x00

load_seg_fail:
    mov ds, bx
    mov si, offset msg_load_seg_fail
    call print
    cli
    hlt

msg_no_drives:
    .ascii "Error: could not find any bootable devices!"
msg_load_seg_fail:
    .ascii "Error: failed to load one or more segemnts!"

gdt_code:
    .word 0xFFFF
    .word 0x0000
    .byte 0x0
    .byte gdt_a_present | gdt_a_nosys | gdt_a_dpl0 | gdt_a_exec | gdt_a_rw | gdt_a_accessed
    .byte gdt_fl_32b | gdt_fl_pglimit | 0xF
    .byte 0x0

.space 0x200 - 2 - (. - start)
.word 0xaa55

