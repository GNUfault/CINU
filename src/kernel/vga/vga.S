.intel_syntax noprefix

.section .data
cursor_x:      .long 0
cursor_y:      .long 0
logo_center_x: .long 25
logo_center_y: .long 25

.section .bss
.global logo_angle
logo_angle:    .long 0

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
pk_next:
    lodsb
    test al, al
    jz pk_done
    cmp al, 10
    je pk_nl
    cmp al, 32
    jb pk_next
    cmp al, 126
    ja pk_next
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
pk_row:
    push ecx
    mov bl, [edx]
    mov ecx, 8
pk_col:
    test bl, 0x80
    jz pk_skip
    mov byte ptr [eax], 0xC0
    mov byte ptr [eax+1], 0xC0
    mov byte ptr [eax+2], 0xC0
pk_skip:
    shl bl, 1
    add eax, 3
    loop pk_col
    sub eax, 24
    add eax, 3072
    inc edx
    pop ecx
    loop pk_row
    inc dword ptr [cursor_x]
    cmp dword ptr [cursor_x], 128
    jb pk_next
pk_nl:
    mov dword ptr [cursor_x], 0
    inc dword ptr [cursor_y]
pk_done:
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
    sub esp, 16

    mov edi, [0x5000]
    add edi, (966*3)
    mov eax, 8
    imul eax, 1024
    add edi, eax
    mov ecx, 50*50
ul_clear:
    mov byte ptr [edi], 0
    mov byte ptr [edi+1], 0
    mov byte ptr [edi+2], 0
    add edi, 3
    loop ul_clear

    mov eax, [logo_angle]
    imul eax, 3141
    mov [esp], eax

    xor ebx, ebx
ul_row:
    xor ecx, ecx
ul_col:
    mov esi, ecx
    sub esi, 25
    mov edi, ebx
    sub edi, 25

    mov eax, [esp]
    imul eax, eax
    xor edx, edx
    mov ebp, 1000
    idiv ebp
    shr eax, 1
    mov ebp, 1000
    sub ebp, eax
    mov [esp+4], ebp

    mov eax, [esp]
    imul eax, eax
    imul eax, eax
    xor edx, edx
    mov ebp, 6000000
    idiv ebp
    mov ebp, [esp]
    sub ebp, eax
    mov [esp+8], ebp

    mov eax, esi
    imul eax, [esp+4]
    mov edx, edi
    imul edx, [esp+8]
    sub eax, edx
    xor edx, edx
    mov ebp, 1000
    idiv ebp
    add eax, 25
    mov [esp+12], eax

    mov eax, esi
    imul eax, [esp+8]
    mov edx, edi
    imul edx, [esp+4]
    add eax, edx
    xor edx, edx
    mov ebp, 1000
    idiv ebp
    add eax, 25
    mov edx, eax

    mov eax, [esp+12]
    cmp eax, 0
    jl ul_skip
    cmp eax, 49
    jg ul_skip
    cmp edx, 0
    jl ul_skip
    cmp edx, 49
    jg ul_skip

    mov esi, edx
    imul esi, 50
    add esi, eax
    lea esi, [esi + esi*2]
    add esi, logo_data

    mov edi, [0x5000]
    add edi, (966*3)
    mov eax, ebx
    add eax, 8
    imul eax, 1024
    add edi, eax
    lea eax, [ecx + ecx*2]
    add edi, eax

    mov al, [esi]
    mov dl, [esi+1]
    mov dh, [esi+2]
    mov byte ptr [edi], al
    mov byte ptr [edi+1], dl
    mov byte ptr [edi+2], dh

ul_skip:
    inc ecx
    cmp ecx, 50
    jl ul_col
    inc ebx
    cmp ebx, 50
    jl ul_row

    add esp, 16
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
