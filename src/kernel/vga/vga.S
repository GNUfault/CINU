.intel_syntax noprefix
.global printk

.section .bss
.align 4
cursor_pos:
    .long 0

.section .text

scroll:
    mov esi, 0xB8000 + 160
    mov edi, 0xB8000
    mov ecx, 1920
.sc_loop:
    mov ax, [esi]
    mov [edi], ax
    add esi, 2
    add edi, 2
    loop .sc_loop
    mov ecx, 80
.clr_loop:
    mov byte ptr [edi], ' '
    mov byte ptr [edi + 1], 0x07
    add edi, 2
    loop .clr_loop
    mov eax, [cursor_pos]
    sub eax, 80
    mov [cursor_pos], eax
    ret

printk:
    push ebp
    mov ebp, esp
    mov esi, [ebp + 8]
.pk_loop:
    mov eax, [cursor_pos]
    cmp eax, 2000
    jl .pos_ok
    call scroll
.pos_ok:
    mov eax, [cursor_pos]
    shl eax, 1
    add eax, 0xB8000
    mov edi, eax
    lodsb
    test al, al
    jz .pk_done
    cmp al, 10
    jne .pk_char
    mov eax, [cursor_pos]
    mov edx, 0
    mov ecx, 80
    div ecx
    inc eax
    mul ecx
    mov [cursor_pos], eax
    jmp .pk_loop
.pk_char:
    mov [edi], al
    mov byte ptr [edi + 1], 0x07
    inc dword ptr [cursor_pos]
    jmp .pk_loop
.pk_done:
    pop ebp
    ret
