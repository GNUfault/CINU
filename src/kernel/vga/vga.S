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
    mov eax, dword ptr [cursor_pos]
    mov edi, dword ptr [vga_base]
    shl eax, 1
    add edi, eax
.next_char:
    lodsb
    cmp al, 0
    je .update_cursor
    cmp al, 10
    jne .print_char
    mov eax, dword ptr [cursor_pos]
    xor edx, edx
    mov ecx, 80
    div ecx
    imul eax, 80
    add eax, 80
    cmp eax, 2000
    jl .update_edi
.scroll:
    mov esi, dword ptr [vga_base]
    add esi, 160
    mov edi, dword ptr [vga_base]
    mov ecx, 24*80
.copy_loop:
    mov al, byte ptr [esi]
    mov byte ptr [edi], al
    mov al, byte ptr [esi+1]
    mov byte ptr [edi+1], al
    add esi, 2
    add edi, 2
    dec ecx
    jnz .copy_loop
    mov ecx, 80
.clear_loop:
    mov byte ptr [edi], ' '
    mov byte ptr [edi+1], 0x07
    add edi, 2
    dec ecx
    jnz .clear_loop
    sub eax, 80
.update_edi:
    mov dword ptr [cursor_pos], eax
    mov edi, dword ptr [vga_base]
    shl eax, 1
    add edi, eax
    jmp .next_char
.print_char:
    mov byte ptr [edi], al
    mov byte ptr [edi+1], 0x07
    add edi, 2
    inc dword ptr [cursor_pos]
    cmp dword ptr [cursor_pos], 2000
    jl .next_char
    jmp .scroll
.update_cursor:
    mov eax, dword ptr [cursor_pos]
    mov dx, 0x3D4
    mov al, 0x0F
    out dx, al
    mov dx, 0x3D5
    mov al, byte ptr eax
    out dx, al
    mov dx, 0x3D4
    mov al, 0x0E
    out dx, al
    mov dx, 0x3D5
    mov al, byte ptr [eax+1]
    out dx, al
    ret
