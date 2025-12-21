.intel_syntax noprefix
.extern printk
.extern idt
.global keyboard_init

.section .data
shift_pressed: .byte 0
caps_lock_on: .byte 0
num_lock_on: .byte 0

scancode_to_ascii:
    .byte 0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0, 0
    .byte 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0, 0, 'a', 's'
    .byte 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`', 0, '\\', 'z', 'x', 'c', 'v'
    .byte 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' ', 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, '7', '8', '9', '-', '4', '5', '6', '+', '1'
    .byte '2', '3', '0', '.', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

scancode_to_ascii_shift:
    .byte 0, 0, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', 0, 0
    .byte 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', 0, 0, 'A', 'S'
    .byte 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', '~', 0, '|', 'Z', 'X', 'C', 'V'
    .byte 'B', 'N', 'M', '<', '>', '?', 0, '*', 0, ' ', 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, '7', '8', '9', '-', '4', '5', '6', '+', '1'
    .byte '2', '3', '0', '.', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.section .rodata
char_msg: .asciz "%c"

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
    push esi
    
    in al, 0x60
    movzx ebx, al
    
    cmp bl, 0x2A
    je .left_shift_pressed
    cmp bl, 0x36
    je .right_shift_pressed
    cmp bl, 0xAA
    je .left_shift_released
    cmp bl, 0xB6
    je .right_shift_released
    
    cmp bl, 0x3A
    je .caps_lock_toggle
    
    cmp bl, 0x45
    je .num_lock_toggle
    
    cmp bl, 0x80
    jge .done
    
    mov al, [shift_pressed]
    test al, al
    jnz .use_shift_table
    
    mov al, [caps_lock_on]
    test al, al
    jz .use_normal_table
    
    cmp bl, 0x10
    jl .use_normal_table
    cmp bl, 0x32
    jg .use_normal_table
    
    lea esi, [scancode_to_ascii]
    movzx eax, byte ptr [esi + ebx]
    
    cmp al, 'a'
    jl .print_char
    cmp al, 'z'
    jg .print_char
    sub al, 32
    jmp .print_char
    
.use_shift_table:
    lea esi, [scancode_to_ascii_shift]
    movzx eax, byte ptr [esi + ebx]
    
    mov cl, [caps_lock_on]
    test cl, cl
    jz .print_char
    
    cmp al, 'A'
    jl .print_char
    cmp al, 'Z'
    jg .print_char
    add al, 32
    jmp .print_char
    
.use_normal_table:
    lea esi, [scancode_to_ascii]
    movzx eax, byte ptr [esi + ebx]
    
.print_char:
    test al, al
    jz .done
    
    movzx eax, al
    push eax
    push offset char_msg
    call printk
    add esp, 8
    jmp .done
    
.left_shift_pressed:
.right_shift_pressed:
    mov byte ptr [shift_pressed], 1
    jmp .done
    
.left_shift_released:
.right_shift_released:
    mov byte ptr [shift_pressed], 0
    jmp .done
    
.caps_lock_toggle:
    xor byte ptr [caps_lock_on], 1
    jmp .done
    
.num_lock_toggle:
    xor byte ptr [num_lock_on], 1
    jmp .done
    
.done:
    mov al, 0x20
    out 0x20, al
    
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    iret
