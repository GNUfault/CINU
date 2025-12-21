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

sin_table:
.incbin "src/kernel/vga/sin.tbl"

.section .text
.global printk
.global boot_logo
.global update_logo

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
    imul eax, 16*1024*3
    mov ecx, [cursor_x]
    imul ecx, 8*3
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
    jmp .next
.done:
    pop ebp
    ret

boot_logo:
    call update_logo
    ret

update_logo:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    mov eax, [logo_angle]
    and eax, 255
    mov ebx, eax
    add eax, 64
    and eax, 255
    mov ecx, eax

    lea esi, [sin_table]
    mov eax, [esi + ebx*4]
    mov edx, [esi + ecx*4]
    mov [ebp-4], eax
    mov [ebp-8], edx

    xor ebx, ebx
.row_loop:
    xor ecx, ecx
.col_loop:
    mov eax, ecx
    sub eax, 25
    mov esi, eax

    mov eax, ebx
    sub eax, 25
    mov edi, eax

    mov eax, esi
    imul dword ptr [ebp-8]
    mov esi, eax

    mov eax, edi
    imul dword ptr [ebp-4]
    sub esi, eax

    mov eax, esi
    cdq
    mov edi, 1000
    idiv edi
    add eax, 25
    mov esi, eax

    mov eax, esi
    sub eax, 25
    mov eax, eax
    imul dword ptr [ebp-4]
    mov edx, eax

    mov eax, edi
    imul dword ptr [ebp-8]
    add edx, eax

    mov eax, edx
    cdq
    mov edi, 1000
    idiv edi
    add eax, 25
    mov edi, eax

    test esi, esi
    js .skip
    cmp esi, 50
    jge .skip
    test edi, edi
    js .skip
    cmp edi, 50
    jge .skip

    mov eax, edi
    imul eax, 50
    add eax, esi
    lea esi, [eax + eax*2]
    add esi, logo_data

    mov eax, ebx
    imul eax, 1024
    add eax, ecx
    lea eax, [eax + eax*2]
    mov edi, [0x5000]
    add edi, 974*3
    add edi, eax

    mov al, [esi]
    mov dl, [esi+1]
    mov dh, [esi+2]
    mov [edi], al
    mov [edi+1], dl
    mov [edi+2], dh

.skip:
    inc ecx
    cmp ecx, 50
    jl .col_loop
    inc ebx
    cmp ebx, 50
    jl .row_loop

    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
