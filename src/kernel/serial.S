.intel_syntax noprefix

.global serial_init
.global serial_console_write

serial_init:
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
    
    ret

serial_console_write:
    push ebp
    mov ebp, esp
    push esi
    push ebx
    
    mov esi, [ebp + 8]
    
write_loop:
    lodsb
    
    test al, al
    jz write_done
    
    cmp al, 0x0A
    je write_newline
    
    mov bl, al
    
wait_transmit:
    mov dx, 0x3F8 + 5
    in al, dx
    test al, 0x20
    jz wait_transmit
    
    mov dx, 0x3F8
    mov al, bl
    out dx, al
    
    jmp write_loop

write_newline:
    mov bl, 0x0D
    
wait_cr:
    mov dx, 0x3F8 + 5
    in al, dx
    test al, 0x20
    jz wait_cr
    
    mov dx, 0x3F8
    mov al, bl
    out dx, al
    
    mov bl, 0x0A
    
wait_lf:
    mov dx, 0x3F8 + 5
    in al, dx
    test al, 0x20
    jz wait_lf
    
    mov dx, 0x3F8
    mov al, bl
    out dx, al
    
    jmp write_loop

write_done:
    pop ebx
    pop esi
    pop ebp
    ret
