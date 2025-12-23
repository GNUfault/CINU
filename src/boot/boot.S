.intel_syntax noprefix
.code16

.section .text
.global start

start:
    cli
    xor cx, cx
    mov ss, cx
    mov sp, 0x7C00
    mov ds, cx
    
    mov ah, 0x41
    mov bx, 0x55AA
    int 0x13
    jc no_lba_support
    
    mov si, offset dap
    mov word ptr [si], 0x10
    mov word ptr [si + 2], 1
    mov word ptr [si + 4], 0x7E00
    mov word ptr [si + 6], 0
    mov dword ptr [si + 8], 1
    mov dword ptr [si + 12], 0
    
    mov ah, 0x42
    int 0x13
    jc load_fail
    
load_init:
    mov ax, 0x7E0
    mov ds, ax
    mov si, [0x1C]
    mov cl, [0x2C]

load_segment:
    push cx
    mov eax, [si]
    dec eax
    jnz skip_seg
    
    mov eax, [si + 4]
    shr eax, 9
    inc eax
    
    push si
    mov si, offset dap
    mov dword ptr [si + 8], eax
    mov dword ptr [si + 12], 0
    
    pop di
    push di
    
    mov eax, [di + 16]
    add eax, 511
    shr eax, 9
    
    mov word ptr [si + 2], ax
    mov word ptr [si + 4], 0
    mov word ptr [si + 6], 0x9000
    
    mov ah, 0x42
    int 0x13
    pop si
    jc load_seg_fail

skip_seg:
    pop cx
    add si, 32
    loop load_segment
    
    mov esi, [0x18]
    
    cld
    mov ax, ds
    mov es, ax
    xor di, di
    
    xor eax, eax
    mov al, 23
    stosw
    mov ax, 0x7E08
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
    
    mov al, 0x92
    mov ds:[0x18 + 5], al
    
    mov ax, 0x4F02
    mov bx, 0x4118
    int 0x10
    
    push ds
    xor ax, ax
    mov ds, ax
    mov ax, 0x4F01
    mov cx, 0x118
    mov di, 0x8000
    push di
    pop es
    xor di, di
    int 0x10
    
    mov eax, es:[40]
    xor ebx, ebx
    mov ds, bx
    mov ds:[0x5000], eax
    pop ds
    
    in al, 0x92
    or al, 2
    out 0x92, al
    
    lgdt [0]
    
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
    mov bx, 0x0007
.loop:
    lodsb
    test al, al
    jz .ret
    int 0x10
    jmp .loop
.ret:
    ret

no_lba_support:
    xor bx, bx
    mov ds, bx
    mov si, offset msg_no_lba
    call print
    cli
    hlt

load_fail:
    xor bx, bx
    mov ds, bx
    mov si, offset msg_load_fail
    call print
    cli
    hlt

load_seg_fail:
    xor bx, bx
    mov ds, bx
    mov si, offset msg_load_seg_fail
    call print
    cli
    hlt

dap:
    .word 0x10
    .word 0
    .word 0
    .word 0
    .quad 0

msg_no_lba:
    .asciz "Error: LBA not supported!"

msg_load_fail:
    .asciz "Error: failed to load ELF header!"

msg_load_seg_fail:
    .asciz "Error: failed to load segment!"

gdt_code:
    .word 0xFFFF
    .word 0x0000
    .byte 0x0
    .byte 0x9A
    .byte 0xCF
    .byte 0x0

.space 0x200 - 2 - (. - start)
.word 0xaa55
