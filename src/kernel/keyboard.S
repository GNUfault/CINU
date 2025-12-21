.intel_syntax noprefix
.extern printk
.extern idt
.global keyboard_init

.section .data
shift_pressed: .byte 0
caps_lock_on: .byte 0

scancode_to_ascii:
    .byte 0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0, 0
    .byte 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n', 0, 'a', 's'
    .byte 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`', 0, '\\', 'z', 'x', 'c', 'v'
    .byte 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' '

scancode_to_ascii_shift:
    .byte 0, 0, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', 0, 0
    .byte 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', '\n', 0, 'A', 'S'
    .byte 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', '~', 0, '|', 'Z', 'X', 'C', 'V'
    .byte 'B', 'N', 'M', '<', '>', '?', 0, '*', 0, ' '

.section .bss
char_buffer: .space 2

.section .text
keyboard_init:
    push eax
    push edi
    
    lea edi, [idt + 0x21 * 8]
    lea eax, [keyboard_handler]
    mov dx, ax
    shr eax, 16
    mov [edi], dx
    mov [edi + 2], word ptr 0x0008
    mov [edi + 4], word ptr 0x8E00
    mov [edi + 6], ax
    
    in al, 0x21
    and al, 0xFD
    out 0x21, al
    
    pop edi
    pop eax
    ret

keyboard_handler:
    push eax
    push ebx
    push ecx
    push edx
    
    in al, 0x60
    movzx ebx, al
    
    cmp bl, 0x2A
    je shift_down
    cmp bl, 0x36
    je shift_down
    
    cmp bl, 0xAA
    je shift_up
    cmp bl, 0xB6
    je shift_up
    
    cmp bl, 0x3A
    je caps_toggle
    
    test bl, 0x80
    jnz done
    
    cmp bl, 58
    jge done
    
    lea eax, [scancode_to_ascii]
    mov cl, [shift_pressed]
    test cl, cl
    jz got_table
    lea eax, [scancode_to_ascii_shift]
    
got_table:
    movzx ecx, byte ptr [eax + ebx]
    test cl, cl
    jz done
    
    mov dl, [caps_lock_on]
    test dl, dl
    jz print_it
    
    cmp cl, 'a'
    jl check_upper
    cmp cl, 'z'
    jg check_upper
    sub cl, 32
    jmp print_it
    
check_upper:
    mov dl, [shift_pressed]
    test dl, dl
    jz print_it
    cmp cl, 'A'
    jl print_it
    cmp cl, 'Z'
    jg print_it
    add cl, 32
    
print_it:
    mov [char_buffer], cl
    mov byte ptr [char_buffer + 1], 0
    
    push offset char_buffer
    call printk
    add esp, 4
    jmp done
    
shift_down:
    mov byte ptr [shift_pressed], 1
    jmp done
    
shift_up:
    mov byte ptr [shift_pressed], 0
    jmp done
    
caps_toggle:
    xor byte ptr [caps_lock_on], 1
    jmp done
    
done:
    mov al, 0x20
    out 0x20, al
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    iret
