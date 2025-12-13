.intel_syntax noprefix

.data
.global vga_cursor_x
vga_cursor_x: .byte 0
.global vga_cursor_y
vga_cursor_y: .byte 0
.global vga_cursor_hidden
vga_cursor_hidden: .int 0
.global vga_scrolling_enabled
vga_scrolling_enabled: .int 1
.global current_fg
current_fg: .byte 0x07
.global current_bg
current_bg: .byte 0x00

.global saved_cursor_start
saved_cursor_start: .byte 0
.global saved_cursor_end
saved_cursor_end: .byte 0

.equ VGA_MEM_ADDR, 0xB8000
.equ SCREEN_WIDTH, 80
.equ SCREEN_HEIGHT, 25

.text

.extern outb
.extern inb

.global get_vga_color
get_vga_color:
    push ebp
    mov ebp, esp
    
    movzx eax, byte ptr [current_bg]
    shl al, 4
    
    movzx edx, byte ptr [current_fg]
    and dl, 0x0F
    or al, dl
    
    movzx eax, al
    
    pop ebp
    ret

.global set_cursor

.global set_cursor
set_cursor:
    push ebp
    mov ebp, esp
    push ebx
    push edx

    mov ebx, [ebp+8]

    mov dx, 0x3D4
    mov al, 0x0F
    push eax
    push edx
    call outb
    add esp, 8

    mov dx, 0x3D5
    mov al, bl
    push eax
    push edx
    call outb
    add esp, 8

    mov dx, 0x3D4
    mov al, 0x0E
    push eax
    push edx
    call outb
    add esp, 8

    mov dx, 0x3D5
    mov al, bh
    push eax
    push edx
    call outb
    add esp, 8

    pop edx
    pop ebx
    pop ebp
    ret

.global vga_hide_cursor
vga_hide_cursor:
    push ebp
    mov ebp, esp
    push ebx
    push edx

    mov eax, [ebp+8]
    cmp eax, 0
    je vga_show_cursor

    mov dx, 0x3D4
    mov al, 0x0A
    push eax
    push edx
    call outb
    add esp, 8

    mov dx, 0x3D5
    push edx
    call inb
    add esp, 4
    mov byte ptr [saved_cursor_start], al

    mov dx, 0x3D4
    mov al, 0x0B
    push eax
    push edx
    call outb
    add esp, 8

    mov dx, 0x3D5
    push edx
    call inb
    add esp, 4
    mov byte ptr [saved_cursor_end], al

    mov dx, 0x3D4
    mov al, 0x0A
    push eax
    push edx
    call outb
    add esp, 8

    mov dx, 0x3D5
    mov al, byte ptr [saved_cursor_start]
    or  al, 0x20
    push eax
    push edx
    call outb
    add esp, 8

    mov dword ptr [vga_cursor_hidden], 1
    jmp vga_hide_cursor_done

vga_show_cursor:
    mov dx, 0x3D4
    mov al, 0x0A
    push eax
    push edx
    call outb
    add esp, 8

    mov dx, 0x3D5
    movzx eax, byte ptr [saved_cursor_start]
    and al, 0xDF
    push eax
    push edx
    call outb
    add esp, 8

    mov dx, 0x3D4
    mov al, 0x0B
    push eax
    push edx
    call outb
    add esp, 8

    mov dx, 0x3D5
    movzx eax, byte ptr [saved_cursor_end]
    push eax
    push edx
    call outb
    add esp, 8

    mov dword ptr [vga_cursor_hidden], 0

vga_hide_cursor_done:
    pop edx
    pop ebx
    pop ebp
    ret

.global scroll_screen
scroll_screen:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push edi
    push esi

    cld

    mov edi, VGA_MEM_ADDR
    mov esi, VGA_MEM_ADDR
    add esi, SCREEN_WIDTH * 2

    mov ecx, SCREEN_HEIGHT - 1
    imul ecx, ecx, SCREEN_WIDTH

    rep movsw

    call get_vga_color
    mov ebx, 0x20
    shl eax, 8
    or ebx, eax

    mov ecx, SCREEN_WIDTH

scroll_clear_loop:
    cmp ecx, 0
    je scroll_clear_done

    mov word ptr [edi], bx
    add edi, 2
    dec ecx
    jmp scroll_clear_loop

scroll_clear_done:
    pop esi
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop ebp
    ret

.global clear_screen
clear_screen:
    push ebp
    mov ebp, esp
    push ebx
    push edi

    call get_vga_color
    mov ebx, 0x20
    shl eax, 8
    or ebx, eax

    mov edi, VGA_MEM_ADDR
    mov ecx, SCREEN_WIDTH * SCREEN_HEIGHT
    mov ax, bx

    cld
    rep stosw

    mov byte ptr [vga_cursor_x], 0
    mov byte ptr [vga_cursor_y], 0

    push 0
    call set_cursor
    add esp, 4

    pop edi
    pop ebx
    pop ebp
    ret

.global vga_hide_cursor
vga_hide_cursor:
    push ebp
    mov ebp, esp
    push ebx
    push edx
    
    mov eax, [ebp+8]
    cmp eax, 0
    je vga_show_cursor
    
    mov dx, 0x3D4
    mov al, 0x0A
    push edx
    push eax
    call outb
    add esp, 8
    
    mov dx, 0x3D5
    push edx
    call inb
    add esp, 4
    mov byte ptr [saved_cursor_start], al
    
    mov dx, 0x3D4
    mov al, 0x0B
    push edx
    push eax
    call outb
    add esp, 8
    
    mov dx, 0x3D5
    push edx
    call inb
    add esp, 4
    mov byte ptr [saved_cursor_end], al
    
    mov dx, 0x3D4
    mov al, 0x0A
    push edx
    push eax
    call outb
    add esp, 8
    
    mov dx, 0x3D5
    mov al, 0x20
    push edx
    push eax
    call outb
    add esp, 8
    
    mov dword ptr [vga_cursor_hidden], 1
    jmp vga_hide_cursor_done
    
vga_show_cursor:
    mov dx, 0x3D4
    mov al, 0x0A
    push edx
    push eax
    call outb
    add esp, 8
    
    mov dx, 0x3D5
    movzx eax, byte ptr [saved_cursor_start]
    push edx
    push eax
    call outb
    add esp, 8
    
    mov dx, 0x3D4
    mov al, 0x0B
    push edx
    push eax
    call outb
    add esp, 8
    
    mov dx, 0x3D5
    movzx eax, byte ptr [saved_cursor_end]
    push edx
    push eax
    call outb
    add esp, 8
    
    mov dword ptr [vga_cursor_hidden], 0
    
vga_hide_cursor_done:
    pop edx
    pop ebx
    pop ebp
    ret

.global scroll_screen
scroll_screen:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push edi
    push esi
    
    mov edi, VGA_MEM_ADDR
    mov esi, VGA_MEM_ADDR
    add esi, SCREEN_WIDTH * 2
    
    mov ecx, SCREEN_HEIGHT - 1
    imul ecx, ecx, SCREEN_WIDTH
    
    rep movsw
    
    call get_vga_color
    mov ebx, 0x20
    shl eax, 8
    or ebx, eax
    
    mov ecx, SCREEN_WIDTH
    
scroll_clear_loop:
    cmp ecx, 0
    je scroll_clear_done
    
    mov word ptr [edi], bx
    add edi, 2
    
    dec ecx
    jmp scroll_clear_loop
    
scroll_clear_done:
    
    pop esi
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop ebp
    ret

.global vga_putchar
vga_putchar:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov bl, byte ptr [ebp+8]
    
    call get_vga_color
    mov bh, al
    
    movzx esi, byte ptr [vga_cursor_x]
    movzx edi, byte ptr [vga_cursor_y]
    
    cmp bl, 0x0A
    je handle_newline
    
    cmp bl, 0x0D
    je handle_carriage_return
    
    cmp bl, 0x08
    je handle_backspace
    
    cmp bl, 0x09
    je handle_tab
    
    jmp handle_normal_char
    
handle_newline:
    mov byte ptr [vga_cursor_x], 0
    inc byte ptr [vga_cursor_y]
    jmp update_cursor_position
    
handle_carriage_return:
    mov byte ptr [vga_cursor_x], 0
    jmp update_cursor_position
    
handle_backspace:
    cmp esi, 0
    jg bs_decr_x
    
    cmp edi, 0
    jle bs_exit
    
    dec byte ptr [vga_cursor_y]
    movzx edi, byte ptr [vga_cursor_y]
    mov byte ptr [vga_cursor_x], SCREEN_WIDTH - 1
    movzx esi, byte ptr [vga_cursor_x]
    jmp bs_write_space
    
bs_decr_x:
    dec byte ptr [vga_cursor_x]
    movzx esi, byte ptr [vga_cursor_x]
    
bs_write_space:
    mov eax, edi
    imul eax, eax, SCREEN_WIDTH
    add eax, esi
    
    movzx ecx, bh
    shl ecx, 8
    or ecx, 0x20
    
    mov word ptr [VGA_MEM_ADDR + eax * 2], cx
    
    jmp update_cursor_position
    
bs_exit:
    jmp update_cursor_position
    
handle_tab:
    add byte ptr [vga_cursor_x], 8
    and byte ptr [vga_cursor_x], 0xF8
    movzx esi, byte ptr [vga_cursor_x]
    
    cmp esi, SCREEN_WIDTH
    jl tab_done_x
    
    mov byte ptr [vga_cursor_x], 0
    inc byte ptr [vga_cursor_y]
    
tab_done_x:
    jmp update_cursor_position
    
handle_normal_char:
    mov eax, edi
    imul eax, eax, SCREEN_WIDTH
    add eax, esi
    
    movzx ecx, bh
    shl ecx, 8
    movzx edx, bl
    or ecx, edx
    
    mov word ptr [VGA_MEM_ADDR + eax * 2], cx
    
    inc byte ptr [vga_cursor_x]
    movzx esi, byte ptr [vga_cursor_x]
    
    cmp esi, SCREEN_WIDTH
    jl normal_done_x
    
    mov byte ptr [vga_cursor_x], 0
    inc byte ptr [vga_cursor_y]
    
normal_done_x:
    
update_cursor_position:
    movzx edi, byte ptr [vga_cursor_y]
    
    cmp edi, SCREEN_HEIGHT
    jl vga_putchar_done
    
    cmp dword ptr [vga_scrolling_enabled], 1
    jne no_scroll
    
    call scroll_screen
    
    mov byte ptr [vga_cursor_y], SCREEN_HEIGHT - 1
    jmp vga_putchar_done
    
no_scroll:
    mov byte ptr [vga_cursor_y], SCREEN_HEIGHT - 1
    mov byte ptr [vga_cursor_x], 0
    
vga_putchar_done:
    movzx eax, byte ptr [vga_cursor_y]
    imul eax, eax, SCREEN_WIDTH
    movzx ebx, byte ptr [vga_cursor_x]
    add eax, ebx
    
    push eax
    call set_cursor
    add esp, 4
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

.global print
print:
    push ebp
    mov ebp, esp
    push ebx
    
    mov ebx, [ebp+8]
    
print_loop:
    movzx eax, byte ptr [ebx]
    cmp al, 0
    je print_done
    
    push eax
    call vga_putchar
    add esp, 4
    
    inc ebx
    jmp print_loop
    
print_done:
    pop ebx
    pop ebp
    ret

.global clear_screen
clear_screen:
    push ebp
    mov ebp, esp
    push ebx
    push edi
    
    call get_vga_color
    mov ebx, 0x20
    shl eax, 8
    or ebx, eax
    
    mov edi, VGA_MEM_ADDR
    mov ecx, SCREEN_WIDTH * SCREEN_HEIGHT
    mov ax, bx
    
    rep stosw
    
    mov byte ptr [vga_cursor_x], 0
    mov byte ptr [vga_cursor_y], 0
    
    push 0
    call set_cursor
    add esp, 4
    
    pop edi
    pop ebx
    pop ebp
    ret
