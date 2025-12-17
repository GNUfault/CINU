[BITS 32]

global printk
global clear_screen

clear_screen:
    pushad
    mov edi, VGA_MEMORY
    mov ecx, VGA_WIDTH * VGA_HEIGHT
    mov ax, (COLOR_ATTR << 8) | ' '
    rep stosw
    mov byte [cursor_x], 0
    mov byte [cursor_y], 0
    call update_hw_cursor
    popad
    ret

printk:
    push ebp
    mov ebp, esp
    pushad
    mov esi, [ebp + 8]
    
.loop:
    lodsb
    test al, al
    jz .done
    cmp al, 0x0A
    je .newline
    call print_char
    jmp .loop
    
.newline:
    mov byte [cursor_x], 0
    inc byte [cursor_y]
    cmp byte [cursor_y], VGA_HEIGHT
    jl .loop
    call scroll_screen
    dec byte [cursor_y]
    jmp .loop
    
.done:
    call update_hw_cursor
    popad
    pop ebp
    ret

print_char:
    push eax
    push ebx
    push edx
    movzx eax, byte [cursor_y]
    mov ebx, VGA_WIDTH
    mul ebx
    movzx ebx, byte [cursor_x]
    add eax, ebx
    shl eax, 1
    mov ebx, VGA_MEMORY
    add ebx, eax
    pop edx
    push edx
    mov [ebx], dl
    mov byte [ebx + 1], COLOR_ATTR
    inc byte [cursor_x]
    cmp byte [cursor_x], VGA_WIDTH
    jl .done
    mov byte [cursor_x], 0
    inc byte [cursor_y]
    cmp byte [cursor_y], VGA_HEIGHT
    jl .done
    call scroll_screen
    dec byte [cursor_y]
    
.done:
    pop edx
    pop ebx
    pop eax
    ret

scroll_screen:
    pushad
    mov esi, VGA_MEMORY + (VGA_WIDTH * 2)
    mov edi, VGA_MEMORY
    mov ecx, VGA_WIDTH * (VGA_HEIGHT - 1)
    rep movsw
    mov edi, VGA_MEMORY + (VGA_WIDTH * (VGA_HEIGHT - 1) * 2)
    mov ecx, VGA_WIDTH
    mov ax, (COLOR_ATTR << 8) | ' '
    rep stosw
    popad
    ret

update_hw_cursor:
    pushad
    movzx eax, byte [cursor_y]
    mov ebx, VGA_WIDTH
    mul ebx
    movzx ebx, byte [cursor_x]
    add eax, ebx
    mov ebx, eax
    mov al, 0x0E
    mov dx, 0x3D4
    out dx, al
    mov al, bh
    mov dx, 0x3D5
    out dx, al
    mov al, 0x0F
    mov dx, 0x3D4
    out dx, al
    mov al, bl
    mov dx, 0x3D5
    out dx, al
    popad
    ret

section .data
    cursor_x db 0
    cursor_y db 0
    VGA_WIDTH equ 80
    VGA_HEIGHT equ 25
    VGA_MEMORY equ 0xB8000
    COLOR_ATTR equ 0x07
