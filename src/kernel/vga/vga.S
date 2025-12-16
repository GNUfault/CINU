.intel_syntax noprefix
.section .data
cursor_pos:
    .long 0
vga_base:
    .long 0xB8000

.section .text
.global printk

printk:
    mov esi, edi
    mov eax, [cursor_pos]
    mov edi, [vga_base]
    shl eax, 1
    add edi, eax
.next_char:
    lodsb
    cmp al, 0
    je .update_cursor
    cmp al, 10
    jne .print_char
    mov eax, [cursor_pos]
    mov edx, eax
    mov ecx, 80
    sub eax, (eax / 80) * 80
    add eax, 80
    cmp eax, 2000
    jl .update_edi
.scroll:
    mov esi, [vga_base]
    add esi, 160
    mov edi, [vga_base]
    mov ecx, 24*80
.copy_loop:
    mov al, [esi]
    mov [edi], al
    mov al, [esi+1]
    mov [edi+1], al
    add esi, 2
    add edi, 2
    dec ecx
    jnz .copy_loop
    mov ecx, 80
.clear_loop:
    mov byte [edi], ' '
    mov byte [edi+1], 0x07
    add edi, 2
    dec ecx
    jnz .clear_loop
    sub eax, 80
.update_edi:
    mov [cursor_pos], eax
    mov edi, [vga_base]
    shl eax, 1
    add edi, eax
    jmp .next_char
.print_char:
    mov [edi], al
    mov byte [edi+1], 0x07
    add edi, 2
    inc dword [cursor_pos]
    cmp dword [cursor_pos], 2000
    jl .next_char
    jmp .scroll
.update_cursor:
    mov eax, [cursor_pos]
    mov dx, 0x3D4
    mov al, 0x0F
    out dx, al
    mov al, al
    mov dx, 0x3D5
    mov al, al
    out dx, al
    mov dx, 0x3D4
    mov al, 0x0E
    out dx, al
    mov al, ah
    mov dx, 0x3D5
    out dx, al
    ret
