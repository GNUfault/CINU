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
    push rbp
    mov rbp, rsp
    
    movzx eax, byte ptr [current_bg]
    shl al, 4
    
    movzx edx, byte ptr [current_fg]
    and dl, 0x0F
    or al, dl
    
    movzx eax, al
    
    pop rbp
    ret

.global set_cursor
set_cursor:
    push rbp
    mov rbp, rsp
    push rbx
    push rdx
    
    movzx ebx, di
    
    mov dx, 0x3D4
    mov al, 0x0F
    call outb
    
    mov dx, 0x3D5
    mov al, bl
    call outb
    
    mov dx, 0x3D4
    mov al, 0x0E
    call outb
    
    mov dx, 0x3D5
    mov al, bh
    call outb
    
    pop rdx
    pop rbx
    pop rbp
    ret

.global vga_hide_cursor
vga_hide_cursor:
    push rbp
    mov rbp, rsp
    push rbx
    push rdx
    
    cmp edi, 0
    je vga_show_cursor
    
    mov dx, 0x3D4
    mov al, 0x0A
    call outb
    mov dx, 0x3D5
    call inb
    mov byte ptr [saved_cursor_start], al
    
    mov dx, 0x3D4
    mov al, 0x0B
    call outb
    mov dx, 0x3D5
    call inb
    mov byte ptr [saved_cursor_end], al
    
    mov dx, 0x3D4
    mov al, 0x0A
    call outb
    mov dx, 0x3D5
    mov al, 0x20
    call outb
    
    mov dword ptr [vga_cursor_hidden], 1
    jmp vga_hide_cursor_done
    
vga_show_cursor:
    
    mov dx, 0x3D4
    mov al, 0x0A
    call outb
    mov dx, 0x3D5
    mov al, byte ptr [saved_cursor_start]
    call outb
    
    mov dx, 0x3D4
    mov al, 0x0B
    call outb
    mov dx, 0x3D5
    mov al, byte ptr [saved_cursor_end]
    call outb
    
    mov dword ptr [vga_cursor_hidden], 0
    
vga_hide_cursor_done:
    pop rdx
    pop rbx
    pop rbp
    ret

.global scroll_screen
scroll_screen:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    
    mov rdi, VGA_MEM_ADDR
    mov rsi, VGA_MEM_ADDR
    add rsi, SCREEN_WIDTH * 2
    
    mov rcx, SCREEN_HEIGHT - 1
    imul rcx, SCREEN_WIDTH
    
    rep movsw
    
    call get_vga_color
    mov r12d, 0x20
    shl eax, 8
    or r12d, eax
    
    mov rcx, SCREEN_WIDTH
    
scroll_clear_loop:
    cmp rcx, 0
    je scroll_clear_done
    
    mov word ptr [rdi], r12w
    add rdi, 2
    
    dec rcx
    jmp scroll_clear_loop
    
scroll_clear_done:
    
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rbp
    ret

.global vga_putchar
vga_putchar:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    mov r15b, dil
    
    call get_vga_color
    mov r14b, al
    
    movzx r12, byte ptr [vga_cursor_x]
    movzx r13, byte ptr [vga_cursor_y]
    
    cmp r15b, 0x0A
    je handle_newline
    
    cmp r15b, 0x0D
    je handle_carriage_return
    
    cmp r15b, 0x08
    je handle_backspace
    
    cmp r15b, 0x09
    je handle_tab
    
    jmp handle_normal_char
    
handle_newline:
    mov byte ptr [vga_cursor_x], 0
    inc r13b
    jmp update_cursor_position
    
handle_carriage_return:
    mov byte ptr [vga_cursor_x], 0
    jmp update_cursor_position
    
handle_backspace:
    cmp r12b, 0
    jg bs_decr_x
    
    cmp r13b, 0
    jle bs_exit
    
    dec r13b
    mov byte ptr [vga_cursor_y], r13b
    mov r12b, SCREEN_WIDTH - 1
    mov byte ptr [vga_cursor_x], r12b
    jmp bs_write_space
    
bs_decr_x:
    dec r12b
    mov byte ptr [vga_cursor_x], r12b
    
bs_write_space:
    mov r10, r13
    imul r10, SCREEN_WIDTH
    add r10, r12
    
    mov r11d, 0x20
    mov r12d, r14d
    shl r12d, 8
    or r11d, r12d
    
    mov word ptr [VGA_MEM_ADDR + r10 * 2], r11w
    
    jmp update_cursor_position
    
bs_exit:
    jmp update_cursor_position
    
handle_tab:
    add r12b, 8
    and r12b, 0xF8
    mov byte ptr [vga_cursor_x], r12b
    
    cmp r12b, SCREEN_WIDTH
    jl tab_done_x
    
    mov byte ptr [vga_cursor_x], 0
    inc r13b
    
tab_done_x:
    jmp update_cursor_position
    
handle_normal_char:
    mov r10, r13
    imul r10, SCREEN_WIDTH
    add r10, r12
    
    mov r11d, r15d
    mov r12d, r14d
    shl r12d, 8
    or r11d, r12d
    
    mov word ptr [VGA_MEM_ADDR + r10 * 2], r11w
    
    inc r12b
    mov byte ptr [vga_cursor_x], r12b
    
    cmp r12b, SCREEN_WIDTH
    jl normal_done_x
    
    mov byte ptr [vga_cursor_x], 0
    inc r13b
    
normal_done_x:
    
update_cursor_position:
    movzx r13, byte ptr [vga_cursor_y]
    
    cmp r13b, SCREEN_HEIGHT
    jl vga_putchar_done
    
    cmp dword ptr [vga_scrolling_enabled], 1
    jne no_scroll
    
    call scroll_screen
    
    mov r13b, SCREEN_HEIGHT - 1
    mov byte ptr [vga_cursor_y], r13b
    jmp vga_putchar_done
    
no_scroll:
    mov r13b, SCREEN_HEIGHT - 1
    mov byte ptr [vga_cursor_y], r13b
    mov byte ptr [vga_cursor_x], 0
    
vga_putchar_done:
    movzx eax, byte ptr [vga_cursor_y]
    imul eax, SCREEN_WIDTH
    movzx ebx, byte ptr [vga_cursor_x]
    add eax, ebx
    
    mov edi, eax
    call set_cursor
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

.global print
print:
    push rbp
    mov rbp, rsp
    push rbx
    
print_loop:
    movzx ebx, byte ptr [rdi]
    cmp bl, 0
    je print_done
    
    movzx edi, bl
    call vga_putchar
    
    inc rdi
    jmp print_loop
    
print_done:
    pop rbx
    pop rbp
    ret

.global clear_screen
clear_screen:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    
    call get_vga_color
    mov r12d, 0x20
    shl eax, 8
    or r12d, eax
    
    mov rdi, VGA_MEM_ADDR
    mov rcx, SCREEN_WIDTH * SCREEN_HEIGHT
    mov ax, r12w
    
    rep stosw
    
    mov byte ptr [vga_cursor_x], 0
    mov byte ptr [vga_cursor_y], 0
    
    mov edi, 0
    call set_cursor
    
    pop r12
    pop rbx
    pop rbp
    ret
