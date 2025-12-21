.intel_syntax noprefix
.extern idt
.extern printk
.global floppy_init
.global print_bytes

floppy_init:
    push eax
    push edi
    
    lea edi, [idt + 0x26 * 8]
    lea eax, [floppy_handler]
    mov dx, ax
    shr eax, 16
    mov [edi], dx
    mov [edi + 2], word ptr 0x0008
    mov [edi + 4], word ptr 0x8E00
    mov [edi + 6], ax
    
    in al, 0x21
    and al, 0xBF
    out 0x21, al
    
    mov al, 0x06
    out 0x0A, al
    
    mov al, 0x00
    out 0x0C, al
    
    mov al, 0x00
    out 0x04, al
    mov al, 0x10
    out 0x04, al
    
    mov al, 0x00
    out 0x05, al
    mov al, 0x02
    out 0x05, al
    
    mov al, 0x46
    out 0x0B, al
    
    mov al, 0x02
    out 0x0A, al
    
    mov dx, 0x3F2
    mov al, 0x00
    out dx, al
    
    mov ecx, 1000000
delay1:
    pause
    dec ecx
    jnz delay1
    
    mov dx, 0x3F2
    mov al, 0x0C
    out dx, al
    
    mov ecx, 1000000
delay2:
    pause
    dec ecx
    jnz delay2
    
    mov dx, 0x3F7
    in al, dx
    
    mov dx, 0x3F4
wait_rdy:
    in al, dx
    test al, 0x80
    jz wait_rdy
    
    mov dx, 0x3F5
    mov al, 0x03
    out dx, al
    
    mov dx, 0x3F4
wait_rdy2:
    in al, dx
    test al, 0x80
    jz wait_rdy2
    
    mov dx, 0x3F5
    mov al, 0xDF
    out dx, al
    
    mov dx, 0x3F4
wait_rdy3:
    in al, dx
    test al, 0x80
    jz wait_rdy3
    
    mov dx, 0x3F5
    mov al, 0x02
    out dx, al
    
    pop edi
    pop eax
    ret

floppy_handler:
    push eax
    
    mov byte ptr [floppy_irq_fired], 1
    
    mov al, 0x20
    out 0x20, al
    
    pop eax
    iret

print_bytes:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    
    mov byte ptr [floppy_irq_fired], 0
    
    mov dx, 0x3F2
    mov al, 0x1C
    out dx, al
    
    mov dx, 0x3F4
wait_motor:
    in al, dx
    test al, 0x80
    jz wait_motor
    
    mov dx, 0x3F5
    mov al, 0x07
    out dx, al
    
    mov dx, 0x3F4
wait_seek1:
    in al, dx
    test al, 0x80
    jz wait_seek1
    
    mov dx, 0x3F5
    mov al, 0x00
    out dx, al
    
    mov dx, 0x3F4
wait_seek2:
    in al, dx
    test al, 0x80
    jz wait_seek2
    
    mov dx, 0x3F5
    mov al, 0x00
    out dx, al
    
wait_seek_irq:
    cmp byte ptr [floppy_irq_fired], 0
    je wait_seek_irq
    mov byte ptr [floppy_irq_fired], 0
    
    mov dx, 0x3F5
    in al, dx
    in al, dx
    
    mov al, 0x06
    out 0x0A, al
    
    mov al, 0x00
    out 0x0C, al
    
    mov al, 0x00
    out 0x04, al
    mov al, 0x10
    out 0x04, al
    
    mov al, 0xFF
    out 0x05, al
    mov al, 0x01
    out 0x05, al
    
    mov al, 0x02
    out 0x0A, al
    
    mov dx, 0x3F4
wait_read1:
    in al, dx
    test al, 0x80
    jz wait_read1
    
    mov dx, 0x3F5
    mov al, 0x46
    out dx, al
    
    mov dx, 0x3F4
wait_read2:
    in al, dx
    test al, 0x80
    jz wait_read2
    
    mov dx, 0x3F5
    mov al, 0x00
    out dx, al
    
    mov dx, 0x3F4
wait_read3:
    in al, dx
    test al, 0x80
    jz wait_read3
    
    mov dx, 0x3F5
    mov al, 0x00
    out dx, al
    
    mov dx, 0x3F4
wait_read4:
    in al, dx
    test al, 0x80
    jz wait_read4
    
    mov dx, 0x3F5
    mov al, 0x00
    out dx, al
    
    mov dx, 0x3F4
wait_read5:
    in al, dx
    test al, 0x80
    jz wait_read5
    
    mov dx, 0x3F5
    mov al, 0x01
    out dx, al
    
    mov dx, 0x3F4
wait_read6:
    in al, dx
    test al, 0x80
    jz wait_read6
    
    mov dx, 0x3F5
    mov al, 0x01
    out dx, al
    
    mov dx, 0x3F4
wait_read7:
    in al, dx
    test al, 0x80
    jz wait_read7
    
    mov dx, 0x3F5
    mov al, 0x00
    out dx, al
    
    mov dx, 0x3F4
wait_read8:
    in al, dx
    test al, 0x80
    jz wait_read8
    
    mov dx, 0x3F5
    mov al, 0x02
    out dx, al
    
    mov dx, 0x3F4
wait_read9:
    in al, dx
    test al, 0x80
    jz wait_read9
    
    mov dx, 0x3F5
    mov al, 0x12
    out dx, al
    
    mov dx, 0x3F4
wait_read10:
    in al, dx
    test al, 0x80
    jz wait_read10
    
    mov dx, 0x3F5
    mov al, 0xFF
    out dx, al
    
wait_read_irq:
    cmp byte ptr [floppy_irq_fired], 0
    je wait_read_irq
    mov byte ptr [floppy_irq_fired], 0
    
    mov dx, 0x3F5
    in al, dx
    in al, dx
    in al, dx
    in al, dx
    in al, dx
    in al, dx
    in al, dx
    
    mov esi, 0x1000
    mov ecx, 512
    
print_loop:
    push ecx
    
    movzx eax, byte ptr [esi]
    
    lea edi, [hex_buffer]
    
    mov ebx, eax
    shr ebx, 4
    and ebx, 0x0F
    lea edx, [hex_chars]
    add edx, ebx
    movzx ebx, byte ptr [edx]
    mov [edi], bl
    
    inc edi
    mov ebx, eax
    and ebx, 0x0F
    lea edx, [hex_chars]
    add edx, ebx
    movzx ebx, byte ptr [edx]
    mov [edi], bl
    
    inc edi
    mov byte ptr [edi], 0x20
    inc edi
    mov byte ptr [edi], 0x00
    
    lea eax, [hex_buffer]
    push eax
    call printk
    add esp, 4
    
    inc esi
    pop ecx
    dec ecx
    jnz print_loop
    
    lea eax, [newline]
    push eax
    call printk
    add esp, 4
    
    pop ebx
    pop edi
    pop esi
    pop ebp
    ret

.section .data
hex_chars:
    .ascii "0123456789ABCDEF"
newline:
    .asciz "\n"
floppy_irq_fired:
    .byte 0

.section .bss
hex_buffer:
    .skip 4
