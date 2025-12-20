.intel_syntax noprefix
.section .data
cursor_x: .long 0
cursor_y: .long 0

vertices:
    .long -100, -100, -100
    .long  100, -100, -100
    .long  100,  100, -100
    .long -100,  100, -100
    .long -100, -100,  100
    .long  100, -100,  100
    .long  100,  100,  100
    .long -100,  100,  100

edges:
    .byte 0, 1,  1, 2,  2, 3,  3, 0
    .byte 4, 5,  5, 6,  6, 7,  7, 4
    .byte 0, 4,  1, 5,  2, 6,  3, 7
    
colors:
    .byte 0xFF, 0x00, 0x00
    .byte 0xFF, 0x7F, 0x00
    .byte 0xFF, 0xFF, 0x00
    .byte 0x00, 0xFF, 0x00
    .byte 0x00, 0x00, 0xFF
    .byte 0x4B, 0x00, 0x82
    .byte 0x94, 0x00, 0xD3
    .byte 0xFF, 0x00, 0xFF
    .byte 0x00, 0xFF, 0xFF
    .byte 0xFF, 0xFF, 0xFF
    .byte 0x7F, 0xFF, 0x00
    .byte 0xFF, 0x00, 0x7F

angle_x: .long 0
angle_y: .long 0
angle_z: .long 0

transformed: .space 96

sin_table: .space 1440
cos_table: .space 1440

.section .rodata
.global font8x16
font8x16:
.incbin "src/kernel/vga/font.bin"

.section .text
.global printk
.global boot_logo

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

boot_logo:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov dword ptr [ebp-4], 120
.frame_loop:
    call rotate_cube
    
    xor ebx, ebx
.edge_loop:
    cmp ebx, 12
    jge .frame_done
    
    lea esi, [edges]
    movzx eax, byte ptr [esi + ebx*2]
    movzx edx, byte ptr [esi + ebx*2 + 1]
    
    push ebx
    push edx
    push eax
    push ebx
    call draw_line
    add esp, 16
    pop ebx
    
    inc ebx
    jmp .edge_loop
    
.frame_done:
    mov ecx, 0x400000
.delay:
    loop .delay
    
    dec dword ptr [ebp-4]
    jnz .frame_loop
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

rotate_cube:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    add dword ptr [angle_x], 3
    add dword ptr [angle_y], 5
    add dword ptr [angle_z], 7
    
    mov eax, [angle_x]
    cmp eax, 360
    jl .x_ok
    sub eax, 360
    mov [angle_x], eax
.x_ok:
    mov eax, [angle_y]
    cmp eax, 360
    jl .y_ok
    sub eax, 360
    mov [angle_y], eax
.y_ok:
    mov eax, [angle_z]
    cmp eax, 360
    jl .z_ok
    sub eax, 360
    mov [angle_z], eax
.z_ok:
    
    xor ecx, ecx
.vertex_loop:
    cmp ecx, 8
    jge .rotate_done
    
    lea esi, [vertices]
    mov eax, ecx
    imul eax, 12
    mov eax, [esi + eax]
    mov ebx, [esi + eax + 4]
    mov edx, [esi + eax + 8]
    
    push edx
    push ecx
    
    mov ecx, [angle_y]
    sar ecx, 2
    add eax, ecx
    
    mov ecx, [angle_x]
    sar ecx, 2
    add ebx, ecx
    
    pop ecx
    pop edx
    
    push eax
    mov eax, edx
    cdq
    mov edi, 800
    idiv edi
    add eax, 128
    mov edi, eax
    pop eax
    
    imul eax, 128
    cdq
    idiv edi
    add eax, 999
    
    push eax
    
    mov eax, ebx
    imul eax, 128
    cdq
    idiv edi
    add eax, 25
    
    lea esi, [transformed]
    pop ebx
    push ecx
    imul ecx, 12
    mov [esi + ecx], ebx
    mov [esi + ecx + 4], eax
    mov [esi + ecx + 8], edx
    pop ecx
    
    inc ecx
    jmp .vertex_loop
    
.rotate_done:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

draw_line:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov eax, [ebp + 12]
    lea esi, [transformed]
    imul eax, 12
    mov ebx, [esi + eax]
    mov ecx, [esi + eax + 4]
    
    mov eax, [ebp + 16]
    imul eax, 12
    mov edx, [esi + eax]
    mov edi, [esi + eax + 4]
    
    sub edx, ebx
    sub edi, ecx
    
    mov eax, [ebp + 8]
    xor edx, edx
    mov esi, 12
    div esi
    imul edx, 3
    lea esi, [colors]
    movzx eax, byte ptr [esi + edx]
    shl eax, 8
    mov al, byte ptr [esi + edx + 1]
    shl eax, 8
    mov al, byte ptr [esi + edx + 2]
    
    push eax
    mov esi, [0x5000]
    mov eax, 30
.plot_loop:
    push eax
    
    cmp ebx, 0
    jl .skip_plot
    cmp ebx, 1023
    jg .skip_plot
    cmp ecx, 0
    jl .skip_plot
    cmp ecx, 767
    jg .skip_plot
    
    push edx
    push edi
    mov eax, ecx
    imul eax, 1024
    add eax, ebx
    lea edi, [eax + eax*2]
    add edi, esi
    
    pop eax
    mov [edi], ax
    shr eax, 16
    mov [edi+2], al
    pop edx
    
.skip_plot:
    add ebx, edx
    sar ebx, 5
    add ecx, edi
    sar ecx, 5
    
    pop eax
    dec eax
    jnz .plot_loop
    
    pop eax
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
