.intel_syntax noprefix

.section .data
cursor_x: .long 0
cursor_y: .long 0
screen_width: .long 1024
screen_height: .long 768

.section .rodata
.global font8x16
font8x16:
.incbin "src/kernel/vga/font.bin"

.section .text
.global printk
.global draw_logo

printk:
    push ebp
    mov ebp, esp
    mov esi, [ebp+8]
    mov edi, [0x5000]

.next:
    lodsb
    test al, al
    jz .done
    cmp al, 10
    je .newline
    cmp al, 32
    jb .next
    cmp al, 126
    ja .next
    movzx eax, al
    shl eax, 4
    lea edx, [font8x16 + eax]
    mov eax, [cursor_y]
    imul eax, 16
    mov ebx, [screen_width]
    imul eax, ebx
    imul eax, 3
    mov ecx, [cursor_x]
    imul ecx, 8
    imul ecx, 3
    add eax, ecx
    add eax, edi
    mov ecx, 16

.row:
    push ecx
    mov bl, [edx]
    mov ecx, 8

.col:
    test bl, 0x80
    jz .skip
    mov byte ptr [eax], 0xC0
    mov byte ptr [eax+1], 0xC0
    mov byte ptr [eax+2], 0xC0
.skip:
    shl bl, 1
    add eax, 3
    loop .col
    sub eax, 24
    add eax, 3072
    inc edx
    pop ecx
    loop .row
    inc dword ptr [cursor_x]
    cmp dword ptr [cursor_x], 128
    jb .next
.newline:
    mov dword ptr [cursor_x], 0
    inc dword ptr [cursor_y]
.scroll_check:
    mov eax, [cursor_y]
    cmp eax, 48
    jb .next
    mov ebx, [screen_width]
    mov ecx, [screen_height]
    imul ebx, ecx
    imul ebx, 3
    mov ecx, [screen_width]
    imul ecx, 16*3
    sub ebx, ecx
    mov esi, [0x5000]
    add esi, 16*[screen_width]*3
    mov edi, [0x5000]
    mov ecx, ebx
    rep movsb
    mov eax, [cursor_y]
    sub eax, 1
    mov [cursor_y], eax
    mov eax, [cursor_y]
    imul eax, 16
    mov ebx, [screen_width]
    imul eax, ebx
    imul eax, 3
    add eax, edi
    mov ecx, 16
.clear_row:
    push ecx
    mov ecx, 8*3
    xor cl, cl
.clear_pix:
    mov byte ptr [eax], 0x00
    mov byte ptr [eax+1], 0x00
    mov byte ptr [eax+2], 0x00
    add eax, 3
    loop .clear_pix
    pop ecx
    loop .clear_row
    jmp .next
.done:
    mov esp, ebp
    pop ebp
    ret

draw_logo:
    mov edi, [0x5000]
    mov eax, [screen_width]
    sub eax, 50
    mov ebx, eax
    mov ecx, 50
.y_loop:
    push ecx
    mov edx, 50
    mov esi, ecx
.x_loop:
    cmp edx, esi
    ja .skip_pixel
    mov eax, edx
    imul eax, [screen_width]
    add eax, ebx
    imul eax, 3
    add eax, (50 - esi) * 3
    mov al, dl
    mov ah, cl
    mov byte ptr [edi + eax], al
    mov byte ptr [edi + eax +1], ah
    mov byte ptr [edi + eax +2], 255 - al - ah
.skip_pixel:
    dec edx
    jnz .x_loop
    pop ecx
    dec ecx
    jnz .y_loop
    ret
