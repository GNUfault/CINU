.intel_syntax noprefix
.section .text
.globl clear_screen
.globl printk

clear_screen:
    push edi
    push ecx
    mov edi, 0xB8000
    mov ecx, 2000
    mov ax, 0x0F20
    rep stosw
    mov dword ptr [cursor_x], 0
    mov dword ptr [cursor_y], 0
    pop ecx
    pop edi
    ret

printk:
    push ebp
    mov ebp, esp
    push edi
    push esi
    push ebx
    
    mov esi, [ebp + 8]
    lea edi, [ebp + 12]
    
printk_loop:
    lodsb
    test al, al
    jz printk_done
    
    cmp al, '%'
    je printk_format
    
    cmp al, '\n'
    je printk_newline
    
    call putchar
    jmp printk_loop
    
printk_format:
    lodsb
    test al, al
    jz printk_done
    
    cmp al, '%'
    je printk_percent
    
    cmp al, 's'
    je printk_string
    
    cmp al, 'd'
    je printk_decimal
    
    cmp al, 'i'
    je printk_decimal
    
    cmp al, 'u'
    je printk_unsigned
    
    cmp al, 'x'
    je printk_hex
    
    cmp al, 'X'
    je printk_hex
    
    cmp al, 'c'
    je printk_char
    
    cmp al, 'p'
    je printk_pointer
    
    jmp printk_loop

printk_percent:
    mov al, '%'
    call putchar
    jmp printk_loop

printk_newline:
    mov dword ptr [cursor_x], 0
    mov eax, [cursor_y]
    inc eax
    cmp eax, 25
    jl printk_newline_set
    call scroll
    jmp printk_loop
printk_newline_set:
    mov [cursor_y], eax
    jmp printk_loop

printk_string:
    mov ebx, [edi]
    add edi, 4
    test ebx, ebx
    jz printk_loop
printk_string_loop:
    mov al, [ebx]
    test al, al
    jz printk_loop
    call putchar
    inc ebx
    jmp printk_string_loop

printk_char:
    mov eax, [edi]
    add edi, 4
    call putchar
    jmp printk_loop

printk_decimal:
    mov eax, [edi]
    add edi, 4
    test eax, eax
    jns printk_print_number
    neg eax
    push eax
    mov al, '-'
    call putchar
    pop eax
    jmp printk_print_number

printk_unsigned:
    mov eax, [edi]
    add edi, 4
    jmp printk_print_number

printk_hex:
    mov eax, [edi]
    add edi, 4
    mov ecx, 16
    jmp printk_print_num_base

printk_pointer:
    push esi
    mov esi, offset ptr_prefix
printk_ptr_prefix:
    lodsb
    test al, al
    jz printk_ptr_val
    call putchar
    jmp printk_ptr_prefix
printk_ptr_val:
    pop esi
    mov eax, [edi]
    add edi, 4
    mov ecx, 16
    jmp printk_print_num_base

printk_print_number:
    mov ecx, 10

printk_print_num_base:
    push edi
    push esi
    
    mov edi, offset num_buffer + 31
    mov byte ptr [edi], 0
    dec edi
    
    test eax, eax
    jnz printk_convert
    mov byte ptr [edi], '0'
    jmp printk_print_buf

printk_convert:
    xor edx, edx
    div ecx
    cmp edx, 10
    jl printk_digit
    add edx, 'a' - 10
    jmp printk_store
printk_digit:
    add edx, '0'
printk_store:
    mov [edi], dl
    dec edi
    test eax, eax
    jnz printk_convert

printk_print_buf:
    inc edi
printk_print_buf_loop:
    mov al, [edi]
    test al, al
    jz printk_print_buf_done
    call putchar
    inc edi
    jmp printk_print_buf_loop
printk_print_buf_done:
    pop esi
    pop edi
    jmp printk_loop

printk_done:
    pop ebx
    pop esi
    pop edi
    pop ebp
    ret

putchar:
    push eax
    push ebx
    push edx
    
    cmp al, '\n'
    jne putchar_normal
    mov dword ptr [cursor_x], 0
    mov eax, [cursor_y]
    inc eax
    cmp eax, 25
    jl putchar_newline_set
    call scroll
    jmp putchar_done
putchar_newline_set:
    mov [cursor_y], eax
    jmp putchar_done

putchar_normal:
    mov ebx, [cursor_y]
    imul ebx, 80
    add ebx, [cursor_x]
    shl ebx, 1
    add ebx, 0xB8000
    
    mov ah, [vga_color]
    mov [ebx], ax
    
    mov eax, [cursor_x]
    inc eax
    cmp eax, 80
    jl putchar_set_x
    
    mov dword ptr [cursor_x], 0
    mov eax, [cursor_y]
    inc eax
    cmp eax, 25
    jl putchar_set_y
    call scroll
    jmp putchar_done
    
putchar_set_y:
    mov [cursor_y], eax
    jmp putchar_done
    
putchar_set_x:
    mov [cursor_x], eax

putchar_done:
    pop edx
    pop ebx
    pop eax
    ret

scroll:
    push edi
    push esi
    push ecx
    
    mov edi, 0xB8000
    mov esi, 0xB8000 + 160
    mov ecx, 1920
    rep movsw
    
    mov edi, 0xB8000 + 3840
    mov ecx, 80
    mov ah, [vga_color]
    mov al, ' '
    rep stosw
    
    mov dword ptr [cursor_y], 24
    
    pop ecx
    pop esi
    pop edi
    ret

.section .data
cursor_x: .long 0
cursor_y: .long 0
vga_color: .byte 0x0F
ptr_prefix: .asciz "0x"

.section .bss
num_buffer: .space 32
