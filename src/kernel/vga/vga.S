.intel_syntax noprefix
.code32
.section .data
cursor_x: .long 0
cursor_y: .long 0

.section .text
.global printk

printk:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    
    mov esi, [ebp + 8]
    mov edi, [0x5000]
    test edi, edi
    jz .done
    
.loop:
    lodsb
    test al, al
    jz .done
    
    cmp al, 10
    je .newline
    
    call draw_char
    
    inc dword ptr [cursor_x]
    cmp dword ptr [cursor_x], 128
    jl .loop
    
.newline:
    mov dword ptr [cursor_x], 0
    inc dword ptr [cursor_y]
    cmp dword ptr [cursor_y], 96
    jl .loop
    mov dword ptr [cursor_y], 0
    jmp .loop
    
.done:
    pop ebx
    pop edi
    pop esi
    pop ebp
    ret

draw_char:
    push eax
    push ecx
    push edx
    push esi
    
    movzx esi, al
    shl esi, 4
    add esi, 0x60000
    
    mov ecx, [cursor_y]
    imul ecx, 16
    imul ecx, 1024
    mov edx, [cursor_x]
    imul edx, 8
    add ecx, edx
    shl ecx, 1
    add ecx, edi
    
    mov edx, 16
.char_row:
    mov al, [esi]
    inc esi
    push ecx
    mov ah, 8
.char_col:
    test al, 0x80
    jz .skip_pixel
    mov word ptr [ecx], 0xFFFF
.skip_pixel:
    add ecx, 2
    shl al, 1
    dec ah
    jnz .char_col
    pop ecx
    add ecx, 2048
    dec edx
    jnz .char_row
    
    pop esi
    pop edx
    pop ecx
    pop eax
    ret
