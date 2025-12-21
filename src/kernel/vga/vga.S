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
.long 0, 17, 35, 52, 70, 87, 105, 122, 139, 156, 174, 191, 208, 225, 242, 259
.long 276, 292, 309, 326, 342, 358, 375, 391, 407, 423, 438, 454, 469, 485, 500, 515
.long 530, 545, 559, 574, 588, 602, 616, 629, 643, 656, 669, 682, 695, 707, 719, 731
.long 743, 755, 766, 777, 788, 799, 809, 819, 829, 839, 848, 857, 866, 875, 883, 891
.long 899, 906, 914, 921, 927, 934, 940, 946, 951, 956, 961, 966, 970, 974, 978, 982
.long 985, 988, 990, 993, 995, 997, 999, 1000, 1001, 1002, 1003, 1003, 1003, 1003, 1002, 1001
.long 1000, 999, 997, 995, 993, 990, 988, 985, 982, 978, 974, 970, 966, 961, 956, 951
.long 946, 940, 934, 927, 921, 914, 906, 899, 891, 883, 875, 866, 857, 848, 839, 829
.long 819, 809, 799, 788, 777, 766, 755, 743, 731, 719, 707, 695, 682, 669, 656, 643
.long 629, 616, 602, 588, 574, 559, 545, 530, 515, 500, 485, 469, 454, 438, 423, 407
.long 391, 375, 358, 342, 326, 309, 292, 276, 259, 242, 225, 208, 191, 174, 156, 139
.long 122, 105, 87, 70, 52, 35, 17, 0, -17, -35, -52, -70, -87, -105, -122, -139
.long -156, -174, -191, -208, -225, -242, -259, -276, -292, -309, -326, -342, -358, -375, -391, -407
.long -423, -438, -454, -469, -485, -500, -515, -530, -545, -559, -574, -588, -602, -616, -629, -643
.long -656, -669, -682, -695, -707, -719, -731, -743, -755, -766, -777, -788, -799, -809, -819, -829
.long -839, -848, -857, -866, -875, -883, -891, -899, -906, -914, -921, -927, -934, -940, -946, -951
.long -956, -961, -966, -970, -974, -978, -982, -985, -988, -990, -993, -995, -997, -999, -1000, -1001
.long -1002, -1003, -1003, -1003, -1003, -1002, -1001, -1000, -999, -997, -995, -993, -990, -988, -985, -982
.long -978, -974, -970, -966, -961, -956, -951, -946, -940, -934, -927, -921, -914, -906, -899, -891
.long -883, -875, -866, -857, -848, -839, -829, -819, -809, -799, -788, -777, -766, -755, -743, -731
.long -719, -707, -695, -682, -669, -656, -643, -629, -616, -602, -588, -574, -559, -545, -530, -515
.long -500, -485, -469, -454, -438, -423, -407, -391, -375, -358, -342, -326, -309, -292, -276, -259
.long -242, -225, -208, -191, -174, -156, -139, -122, -105, -87, -70, -52, -35, -17

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
    call update_logo
    pop ebp
    ret

update_logo:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    sub esp, 16
    
    mov edi, [0x5000]
    mov eax, 974 * 3
    add edi, eax
    
    mov eax, edi
    mov ecx, 50 * 50 * 3
.clear:
    mov byte ptr [eax], 0x00
    mov byte ptr [eax+1], 0x00
    mov byte ptr [eax+2], 0x00
    add eax, 3
    loop .clear
    
    mov eax, [logo_angle]
    and eax, 0xFF
    mov [ebp-4], eax
    add eax, 64
    and eax, 0xFF
    mov [ebp-8], eax
    
    xor ebx, ebx
.logo_row:
    mov [ebp-12], ebx
    xor ecx, ecx
.logo_col:
    mov [ebp-16], ecx
    
    mov eax, ecx
    sub eax, [logo_center_x]
    mov esi, eax
    
    mov eax, ebx
    sub eax, [logo_center_y]
    mov edi, eax
    
    mov eax, [ebp-4]
    lea edx, [sin_table]
    mov eax, [edx + eax*4]
    imul esi
    mov [ebp-20], eax
    mov [ebp-24], edx
    
    mov eax, [ebp-8]
    lea edx, [sin_table]
    mov eax, [edx + eax*4]
    imul edi
    sub eax, [ebp-20]
    sbb edx, [ebp-24]
    mov esi, 1000
    idiv esi
    add eax, [logo_center_x]
    mov esi, eax
    
    mov eax, [ebp-4]
    lea edx, [sin_table]
    mov eax, [edx + eax*4]
    imul edi
    mov [ebp-20], eax
    mov [ebp-24], edx
    
    mov eax, [ebp-8]
    lea edx, [sin_table]
    mov eax, [edx + eax*4]
    mov edi, [ebp-16]
    sub edi, [logo_center_x]
    imul edi
    add eax, [ebp-20]
    adc edx, [ebp-24]
    mov edi, 1000
    idiv edi
    add eax, [logo_center_y]
    mov edi, eax
    
    test esi, esi
    js .skip_pixel
    cmp esi, 50
    jge .skip_pixel
    test edi, edi
    js .skip_pixel
    cmp edi, 50
    jge .skip_pixel
    
    mov eax, edi
    imul eax, 50
    add eax, esi
    lea edx, [eax + eax*2]
    lea esi, [logo_data]
    add esi, edx
    
    mov eax, [ebp-12]
    imul eax, 1024
    add eax, [ebp-16]
    lea eax, [eax + eax*2]
    mov edi, [0x5000]
    mov edx, 974 * 3
    add edi, edx
    add edi, eax
    
    mov al, [esi]
    mov dl, [esi+1]
    mov dh, [esi+2]
    mov byte ptr [edi], al
    mov byte ptr [edi+1], dl
    mov byte ptr [edi+2], dh
    
.skip_pixel:
    mov ecx, [ebp-16]
    inc ecx
    cmp ecx, 50
    jb .logo_col
    
    mov ebx, [ebp-12]
    inc ebx
    cmp ebx, 50
    jb .logo_row
    
    add esp, 16
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
