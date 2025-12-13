.intel_syntax noprefix

.equ GDT_ENTRY_LIMIT_LOW, 0
.equ GDT_ENTRY_BASE_LOW, 2
.equ GDT_ENTRY_BASE_MIDDLE, 4
.equ GDT_ENTRY_ACCESS, 5
.equ GDT_ENTRY_GRANULARITY, 6
.equ GDT_ENTRY_BASE_HIGH, 7

.equ TSS_PREV_TSS, 0
.equ TSS_ESP0, 4
.equ TSS_SS0, 8
.equ TSS_ESP1, 12
.equ TSS_SS1, 16
.equ TSS_ESP2, 20
.equ TSS_SS2, 24
.equ TSS_CR3, 28
.equ TSS_EIP, 32
.equ TSS_EFLAGS, 36
.equ TSS_EAX, 40
.equ TSS_ECX, 44
.equ TSS_EDX, 48
.equ TSS_EBX, 52
.equ TSS_ESP, 56
.equ TSS_EBP, 60
.equ TSS_ESI, 64
.equ TSS_EDI, 68
.equ TSS_ES, 72
.equ TSS_CS, 76
.equ TSS_SS, 80
.equ TSS_DS, 84
.equ TSS_FS, 88
.equ TSS_GS, 92
.equ TSS_LDT, 96
.equ TSS_TRAP, 100
.equ TSS_IOMAP_BASE, 102

.data
.global gdt
.global gp
.global tss
.global kernel_stack

.align 16
gdt:
    .skip 48

.align 16
gp:
    .word 0
    .long 0

.align 16
tss:
    .skip 104

.align 4096
kernel_stack:
    .skip 4096

.text

.extern gdt_flush
.extern tss_flush

.global gdt_set_entry
gdt_set_entry:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    
    mov eax, [ebp+8]
    shl eax, 3
    lea esi, [gdt + eax]
    
    mov eax, [ebp+16]
    mov word ptr [esi+GDT_ENTRY_LIMIT_LOW], ax
    
    mov eax, [ebp+12]
    mov word ptr [esi+GDT_ENTRY_BASE_LOW], ax
    
    mov eax, [ebp+12]
    shr eax, 16
    mov byte ptr [esi+GDT_ENTRY_BASE_MIDDLE], al
    
    mov al, byte ptr [ebp+20]
    mov byte ptr [esi+GDT_ENTRY_ACCESS], al
    
    mov eax, [ebp+16]
    shr eax, 16
    and al, 0x0F
    mov bl, byte ptr [ebp+24]
    and bl, 0xF0
    or al, bl
    mov byte ptr [esi+GDT_ENTRY_GRANULARITY], al
    
    mov eax, [ebp+12]
    shr eax, 24
    mov byte ptr [esi+GDT_ENTRY_BASE_HIGH], al
    
    pop esi
    pop ebx
    pop ebp
    ret

.global gdt_install
gdt_install:
    push ebp
    mov ebp, esp
    
    mov word ptr [gp], 47
    
    lea eax, [gdt]
    mov dword ptr [gp+2], eax
    
    push 0
    push 0
    push 0
    push 0
    push 0
    call gdt_set_entry
    add esp, 20
    
    push 0xCF
    push 0x9A
    push 0xFFFFFFFF
    push 0
    push 1
    call gdt_set_entry
    add esp, 20
    
    push 0xCF
    push 0x92
    push 0xFFFFFFFF
    push 0
    push 2
    call gdt_set_entry
    add esp, 20
    
    push 0xCF
    push 0xFA
    push 0xFFFFFFFF
    push 0
    push 3
    call gdt_set_entry
    add esp, 20
    
    push 0xCF
    push 0xF2
    push 0xFFFFFFFF
    push 0
    push 4
    call gdt_set_entry
    add esp, 20
    
    lea eax, [gp]
    push eax
    call gdt_flush
    add esp, 4
    
    pop ebp
    ret

.global write_tss
write_tss:
    push ebp
    mov ebp, esp
    push ebx
    push edi
    
    lea ebx, [tss]
    
    mov eax, 103
    
    push 0x40
    push 0x89
    push eax
    push ebx
    mov eax, [ebp+8]
    push eax
    call gdt_set_entry
    add esp, 20
    
    mov edi, ebx
    mov ecx, 104
    xor al, al
    rep stosb
    
    mov eax, [ebp+16]
    mov dword ptr [tss+TSS_ESP0], eax
    
    mov ax, word ptr [ebp+12]
    mov word ptr [tss+TSS_SS0], ax
    
    mov word ptr [tss+TSS_IOMAP_BASE], 104
    
    pop edi
    pop ebx
    pop ebp
    ret

.global tss_install
tss_install:
    push ebp
    mov ebp, esp
    
    lea eax, [kernel_stack+4096]
    
    push eax
    push 0x10
    push 5
    call write_tss
    add esp, 12
    
    push 0x28
    call tss_flush
    add esp, 4
    
    pop ebp
    ret
