.intel_syntax noprefix

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
    
    mov eax, [ebp+12]
    mov word ptr [esi], ax
    
    shr eax, 16
    mov byte ptr [esi+2], al
    
    mov eax, [ebp+12]
    shr eax, 24
    mov byte ptr [esi+7], al
    
    mov eax, [ebp+16]
    mov word ptr [esi+0], ax
    
    mov eax, [ebp+16]
    shr eax, 16
    and al, 0x0F
    mov bl, byte ptr [ebp+20]
    and bl, 0xF0
    or al, bl
    mov byte ptr [esi+6], al
    
    mov al, byte ptr [ebp+20]
    mov byte ptr [esi+5], al
    
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
    
    mov ax, word ptr [ebp+12]
    mov word ptr [tss+8], ax
    
    mov eax, [ebp+16]
    mov dword ptr [tss+4], eax
    
    mov word ptr [tss+102], 104
    
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
