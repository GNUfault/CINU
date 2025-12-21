.intel_syntax noprefix

.extern idt

.global serial_init
.global serial_console_write

serial_init:
    push eax
    push edi
    
    mov dx, 0x3F8 + 1
    mov al, 0x00
    out dx, al
    
    mov dx, 0x3F8 + 3
    mov al, 0x80
    out dx, al
    
    mov dx, 0x3F8 + 0
    mov al, 0x03
    out dx, al
    
    mov dx, 0x3F8 + 1
    mov al, 0x00
    out dx, al
    
    mov dx, 0x3F8 + 3
    mov al, 0x03
    out dx, al
    
    mov dx, 0x3F8 + 2
    mov al, 0xC7
    out dx, al
    
    mov dx, 0x3F8 + 4
    mov al, 0x0B
    out dx, al
    
    lea edi, [idt + 0x24 * 8]
    lea eax, [serial_handler]
    mov dx, ax
    shr eax, 16
    mov [edi], dx
    mov [edi + 2], word ptr 0x0008
    mov [edi + 4], word ptr 0x8E00
    mov [edi + 6], ax
    
    mov dx, 0x3F8 + 1
    mov al, 0x01
    out dx, al
    
    in al, 0x21
    and al, 0xEF
    out 0x21, al
    
    pop edi
    pop eax
    ret

serial_handler:
    push eax
    push ebx
    push esi
    push edi
    
    mov dx, 0x3F8 + 5
    in al, dx
    test al, 0x20
    jz serial_done
    
    mov esi, [write_buffer_read]
    mov edi, [write_buffer_write]
    
    cmp esi, edi
    je serial_done
    
    lea ebx, [write_buffer]
    add ebx, esi
    mov al, [ebx]
    
    mov dx, 0x3F8
    out dx, al
    
    inc esi
    and esi, 4095
    mov [write_buffer_read], esi

serial_done:
    mov al, 0x20
    out 0x20, al
    
    pop edi
    pop esi
    pop ebx
    pop eax
    iret

serial_console_write:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    
    mov esi, [ebp + 8]
    
write_loop:
    lodsb
    
    test al, al
    jz write_done
    
    cmp al, 0x0A
    je write_newline_start
    
write_char:
    mov bl, al
    
wait_space:
    mov edi, [write_buffer_write]
    mov ecx, edi
    inc ecx
    and ecx, 4095
    cmp ecx, [write_buffer_read]
    je wait_space
    
    lea eax, [write_buffer]
    add eax, edi
    mov [eax], bl
    
    mov [write_buffer_write], ecx
    
    jmp write_loop

write_newline_start:
    mov bl, 0x0D
    
wait_space_cr:
    mov edi, [write_buffer_write]
    mov ecx, edi
    inc ecx
    and ecx, 4095
    cmp ecx, [write_buffer_read]
    je wait_space_cr
    
    lea eax, [write_buffer]
    add eax, edi
    mov [eax], bl
    
    mov [write_buffer_write], ecx
    
    mov bl, 0x0A
    
wait_space_lf:
    mov edi, [write_buffer_write]
    mov ecx, edi
    inc ecx
    and ecx, 4095
    cmp ecx, [write_buffer_read]
    je wait_space_lf
    
    lea eax, [write_buffer]
    add eax, edi
    mov [eax], bl
    
    mov [write_buffer_write], ecx
    
    jmp write_loop

write_done:
    pop ebx
    pop edi
    pop esi
    pop ebp
    ret

.section .data
write_buffer_read:
    .long 0
write_buffer_write:
    .long 0

.section .bss
write_buffer:
    .skip 4096
