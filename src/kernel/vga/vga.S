.intel_syntax noprefix

.section .data
cursor_x: .long 0
cursor_y: .long 0

.section .rodata
.global font8x16
font8x16:
.incbin "src/kernel/vga/font.bin"

.section .text
.global printk

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
    imul eax, 1024
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

    mov ecx, (1024*768*3 - 16*1024*3)
    mov esi, [0x5000]
    add esi, 16*1024*3
    mov edi, [0x5000]
    rep movsb

    mov eax, [cursor_y]
    sub eax, 1
    mov [cursor_y], eax

    mov eax, [cursor_y]
    imul eax, 16
    imul eax, 1024
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
