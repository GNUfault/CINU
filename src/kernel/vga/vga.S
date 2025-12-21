.intel_syntax noprefix

.section .data
cursor_x: .long 0
cursor_y: .long 0
logo_center_x: .long 25
logo_center_y: .long 25

.section .bss
.global logo_angle
logo_angle: .long 0

.section .rodata
.global font8x16
font8x16:
.incbin "src/kernel/vga/font.bin"
logo_data:
.incbin "src/kernel/vga/logo.bgr"

.section .text
.global printk
.global boot_logo
.global update_logo

printk:
    push ebp
    mov ebp, esp
    mov esi, [ebp+8]
    mov edi, [0x5000]
.next_char:
    lodsb
    test al, al
    jz .done
    cmp al, 10
    je .newline
    cmp al, 32
    jb .next_char
    cmp al, 126
    ja .next_char
    movzx eax, al
    shl eax, 4
    lea edx, [font8x16 + eax]
    mov eax, [cursor_y]
    imul eax, 16*1024*3
    mov ecx, [cursor_x]
    imul ecx, 8*3
    add eax, ecx
    add eax, edi
    mov ecx, 16
.row:
    push ecx
    mov bl, [edx]
.col:
    test bl, 0x80
    jz .skip_pixel
    mov byte ptr [eax], 0xC0
    mov byte ptr [eax+1], 0xC0
    mov byte ptr [eax+2], 0xC0
.skip_pixel:
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
    jb .next_char
.newline:
    mov dword ptr [cursor_x], 0
    inc dword ptr [cursor_y]
.scroll_check:
    mov eax, [cursor_y]
    cmp eax, 48
    jb .next_char
    mov ecx, 1024*768*3 - 16*1024*3
    mov esi, [0x5000]
    add esi, 16*1024*3
    mov edi, [0x5000]
    rep movsb
    sub dword ptr [cursor_y], 1
    mov eax, [cursor_y]
    imul eax, 16*1024*3
    add eax, edi
    mov ecx, 16*8
.clear_bottom:
    mov byte ptr [eax], 0
    mov byte ptr [eax+1], 0
    mov byte ptr [eax+2], 0
    add eax, 3
    loop .clear_bottom
    jmp .next_char
.done:
    mov esp, ebp
    pop ebp
    ret

boot_logo:
    push ebp
    mov ebp, esp
    call update_logo
    pop ebp
    ret

update_logo:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    mov edi, [0x5000]
    add edi, 974*3
    mov ecx, 50*50
    xor eax, eax
.clear_loop:
    mov byte ptr [edi], 0
    mov byte ptr [edi+1], 0
    mov byte ptr [edi+2], 0
    add edi, 3
    inc eax
    cmp eax, 50*50
    jl .clear_loop
    mov eax, [logo_angle]
    mov ebx, eax
    imul ebx, 3141
    mov [ebp-4], ebx
    xor ebx, ebx
.row_loop:
    xor ecx, ecx
.col_loop:
    mov esi, ecx
    sub esi, [logo_center_x]
    mov edx, ebx
    sub edx, [logo_center_y]
    mov eax, [ebp-4]
    mov edi, eax
    imul eax, eax
    idiv 1000
    mov ecx, eax
    mov eax, 1000
    sub eax, ecx/2
    mov [ebp-8], eax
    mov eax, [ebp-4]
    imul eax, eax
    imul eax, eax
    idiv 6
    mov [ebp-12], eax
    mov eax, [ebp-4]
    sub eax, [ebp-12]
    mov [ebp-16], eax
    mov eax, esi
    imul eax, [ebp-8]
    mov edx, edx
    imul edx, [ebp-16]
    sub eax, edx
    idiv 1000
    add eax, [logo_center_x]
    mov edx, esi
    imul edx, [ebp-16]
    mov esi, edx
    imul esi, [ebp-8]
    add edx, esi
    idiv 1000
    add edx, [logo_center_y]
    cmp eax, 0
    jl .skip_pixel
    cmp eax, 49
    jg .skip_pixel
    cmp edx, 0
    jl .skip_pixel
    cmp edx, 49
    jg .skip_pixel
    mov esi, edx
    imul esi, 50
    add esi, eax
    lea esi, [logo_data + esi*3]
    mov edi, [0x5000]
    add edi, 974*3
    mov eax, ebx
    imul eax, 1024
    add edi, eax
    add edi, ecx
    mov al, [esi]
    mov dl, [esi+1]
    mov dh, [esi+2]
    mov byte ptr [edi], al
    mov byte ptr [edi+1], dl
    mov byte ptr [edi+2], dh
.skip_pixel:
    inc ecx
    cmp ecx, 50
    jl .col_loop
    inc ebx
    cmp ebx, 50
    jl .row_loop
    pop ebx
    pop edi
    pop esi
    pop ebp
    ret
