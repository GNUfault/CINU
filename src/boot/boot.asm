org 0x7C00
[BITS 16]

STACK_TOP equ 0x7C00
SELF_LOAD equ 0x7C00
ELF_HDR_LOAD equ 0x7E00
SECT_SIZE equ 512
SECT_SHIFT equ 9
GEOM_SECTORS equ 18
GEOM_CYLINDERS equ 80
GEOM_HEADS equ 2

elf_phoff equ 0x1C
elf_phnum equ 0x2C
elf_entry equ 0x18
elf_seg_type equ 0x00
elf_seg_file_offset equ 0x04
elf_seg_paddr equ 0x0C
elf_seg_filesz equ 0x10
elf_seg_memsz equ 0x14
elf_seg_struct_size equ 0x20

gdt_fl_pglimit equ 0x80
gdt_fl_32b equ 0x40
gdt_a_present equ 0x80
gdt_a_dpl0 equ 0x00
gdt_a_nosys equ 0x10
gdt_a_exec equ 0x08
gdt_a_conforming equ 0x04
gdt_a_grow_down equ 0x04
gdt_a_rw equ 0x2
gdt_a_accessed equ 0x1

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
    loop load_segment
    
    mov esi, [elf_entry]    ; Fixed: removed ds: prefix
    
    ; GDT setup
    gdtp equ 0
    gdt equ 8
    
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
    
    ; Load code segment descriptor
    lea bx, [gdt_code]      ; Fixed: Added lea instruction
    mov eax, [cs:bx]        ; Fixed: Use bx as pointer
    mov edx, [cs:bx+4]
    stosd
    xchg eax, edx
    stosd
    xchg eax, edx
    stosd
    xchg eax, edx
    stosd
    
    mov al, gdt_a_present | gdt_a_nosys | gdt_a_dpl0 | gdt_a_rw | gdt_a_accessed
    mov [ds:gdt + 8*2 + 5], al  ; Fixed: Use ds: instead of es:
    
    in al, 0x92
    or al, 2
    out 0x92, al
    
    lgdt [gdtp]             ; Fixed: removed es: prefix
    
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    jmp 8:prot32

[BITS 32]
prot32:
    xor eax, eax
    mov al, 16
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    jmp esi

[BITS 16]
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
    push cs
    pop ds
    mov si, msg_no_drives
    call print
    cli
    hlt

load_seg_fail:
    push cs
    pop ds
    mov si, msg_load_seg_fail
    call print
    cli
    hlt

drives:
    db 0x00
    db 0x01
    db 0x00

msg_no_drives:
    db "Error: could not find any bootable devices!", 0

msg_load_seg_fail:
    db "Error: failed to load one or more segments!", 0  ; Fixed typo: "segemnts"

gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x0
    db gdt_a_present | gdt_a_nosys | gdt_a_dpl0 | gdt_a_exec | gdt_a_rw | gdt_a_accessed
    db gdt_fl_32b | gdt_fl_pglimit | 0xF
    db 0x0

times 0x200 - 2 - ($ - $$) db 0
dw 0xaa55
