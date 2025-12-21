.intel_syntax noprefix
.section .data
.global cursor_x
.global cursor_y
cursor_x: .long 0
cursor_y: .long 0

.section .rodata
.global font
font:
.incbin "src/kernel/vga/font.bin"

.section .text
.global printk
printk:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    
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
    
    cmp dword ptr [cursor_y], 48
    jae .scroll
    
.continue_print:
    movzx eax, al
    shl eax, 4
    lea edx, [font + eax]
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

.scroll:
    push eax
    push ecx
    push esi
    push edi
    
    mov esi, edi
    add esi, 16*1024*3
    mov edi, [0x5000]
    mov ecx, 47*16*1024*3/4
    rep movsd
    
    mov edi, [0x5000]
    add edi, 47*16*1024*3
    xor eax, eax
    mov ecx, 16*1024*3/4
    rep stosd
    
    pop edi
    pop esi
    pop ecx
    pop eax
    
    dec dword ptr [cursor_y]
    jmp .continue_print

.done:
    pop ebx
    pop edi
    pop esi
    pop ebp
    ret
