.intel_syntax noprefix

.section .data
cursor_pos:
    .word 0
vga_base:
    .long 0xB8000

.section .text
.global printk
.global clear_screen

clear_screen:
    mov edi, dword ptr [vga_base]
    mov ecx, 2000
.cs_loop:
    mov word ptr [edi], 0x0720
    add edi, 2
    loop .cs_loop
    mov word ptr [cursor_pos], 0
    jmp update_hw_cursor

printk:
    mov esi, edi
    movzx eax, word ptr [cursor_pos]
    mov edi, dword ptr [vga_base]
    shl eax, 1
    add edi, eax

.next:
    lodsb
    test al, al
    jz update_hw_cursor
    cmp al, 10
    je .newline

.char:
    mov byte ptr [edi], al
    mov byte ptr [edi+1], 0x07
    add edi, 2
    inc word ptr [cursor_pos]
    cmp word ptr [cursor_pos], 2000
    jl .next
    jmp .scroll

.newline:
    movzx eax, word ptr [cursor_pos]
    xor edx, edx
    mov ecx, 80
    div ecx
    imul eax, 80
    add eax, 80
    cmp eax, 2000
    jl .set
    jmp .scroll

.scroll:
    mov esi, dword ptr [vga_base]
    add esi, 160
    mov edi, dword ptr [vga_base]
    mov ecx, 24*80
.sl_copy:
    mov ax, word ptr [esi]
    mov word ptr [edi], ax
    add esi, 2
    add edi, 2
    dec ecx
    jnz .sl_copy
    mov ecx, 80
.sl_clear:
    mov word ptr [edi], 0x0720
    add edi, 2
    dec ecx
    jnz .sl_clear
    mov eax, 1920

.set:
    mov word ptr [cursor_pos], ax
    mov edi, dword ptr [vga_base]
    shl eax, 1
    add edi, eax
    jmp .next

update_hw_cursor:
    mov ax, word ptr [cursor_pos]

    mov dx, 0x3D4
    mov al, 0x0F
    out dx, al
    mov dx, 0x3D5
    mov al, al
    out dx, al

    mov dx, 0x3D4
    mov al, 0x0E
    out dx, al
    mov dx, 0x3D5
    mov al, ah
    out dx, al

    ret
