.intel_syntax noprefix
.extern idt
.extern printk
.global floppy_init
.global print_bytes
.global floppy_reset
.global sense_interrupt
.global send_specify
.global wait_controller

floppy_init:
    push eax
    push edi
    
    lea eax, [msg_init]
    push eax
    call printk
    add esp, 4
    
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
    
    mov al, 0x46
    out 0x0B, al
    
    mov al, 0x02
    out 0x0A, al
    
    lea eax, [msg_dma]
    push eax
    call printk
    add esp, 4
    
    lea edi, [idt + 0x26 * 8]
    lea eax, [floppy_handler]
    mov dx, ax
    shr eax, 16
    mov word ptr [edi], dx
    mov word ptr [edi + 2], 0x0008
    mov word ptr [edi + 4], 0x8E00
    mov word ptr [edi + 6], ax
    
    in al, 0x21
    and al, 0xBF
    out 0x21, al
    
    lea eax, [msg_idt]
    push eax
    call printk
    add esp, 4
    
    call floppy_reset
    
    lea eax, [msg_ready]
    push eax
    call printk
    add esp, 4
    
    pop edi
    pop eax
    ret

floppy_reset:
    push eax
    push edx
    
    lea eax, [msg_reset]
    push eax
    call printk
    add esp, 4
    
    mov byte ptr [floppy_irq_fired], 0
    
    mov dx, 0x3F2
    mov al, 0x00
    out dx, al
    
    mov dx, 0x3F7
    mov al, 0x00
    out dx, al
    
    mov dx, 0x3F2
    mov al, 0x0C
    out dx, al
    
    lea eax, [msg_wait_reset]
    push eax
    call printk
    add esp, 4
    
wait_reset_irq:
    cmp byte ptr [floppy_irq_fired], 0
    je wait_reset_irq
    
    lea eax, [msg_irq1]
    push eax
    call printk
    add esp, 4
    
    mov byte ptr [floppy_irq_fired], 0
    
    call sense_interrupt
    call sense_interrupt
    call sense_interrupt
    call sense_interrupt
    
    call send_specify
    
    lea eax, [msg_reset_done]
    push eax
    call printk
    add esp, 4
    
    pop edx
    pop eax
    ret

sense_interrupt:
    push eax
    push edx
    
    call wait_controller
    
    mov dx, 0x3F5
    mov al, 0x08
    out dx, al
    
    call wait_controller
    
    mov dx, 0x3F5
    in al, dx
    
    call wait_controller
    
    mov dx, 0x3F5
    in al, dx
    
    pop edx
    pop eax
    ret

send_specify:
    push eax
    push edx
    
    lea eax, [msg_specify]
    push eax
    call printk
    add esp, 4
    
    call wait_controller
    
    mov dx, 0x3F5
    mov al, 0x03
    out dx, al
    
    call wait_controller
    
    mov dx, 0x3F5
    mov al, 0xDF
    out dx, al
    
    call wait_controller
    
    mov dx, 0x3F5
    mov al, 0x02
    out dx, al
    
    pop edx
    pop eax
    ret

wait_controller:
    push eax
    push edx
    
    mov dx, 0x3F4
wait_loop:
    in al, dx
    and al, 0x80
    jz wait_loop
    
    pop edx
    pop eax
    ret

floppy_handler:
    pushad
    
    mov byte ptr [floppy_irq_fired], 1
    
    mov al, 0x20
    out 0x20, al
    
    popad
    iretd

print_bytes:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    
    lea eax, [msg_print_start]
    push eax
    call printk
    add esp, 4
    
    mov byte ptr [floppy_irq_fired], 0
    
    mov dx, 0x3F2
    mov al, 0x1C
    out dx, al
    
    lea eax, [msg_motor_on]
    push eax
    call printk
    add esp, 4
    
    call wait_controller
    
    mov dx, 0x3F5
    mov al, 0xE6
    out dx, al
    
    lea eax, [msg_cmd_sent]
    push eax
    call printk
    add esp, 4
    
    call wait_controller
    
    mov dx, 0x3F5
    mov al, 0x00
    out dx, al
    
    call wait_controller
    
    mov dx, 0x3F5
    mov al, 0x00
    out dx, al
    
    call wait_controller
    
    mov dx, 0x3F5
    mov al, 0x00
    out dx, al
    
    call wait_controller
    
    mov dx, 0x3F5
    mov al, 0x01
    out dx, al
    
    call wait_controller
    
    mov dx, 0x3F5
    mov al, 0x01
    out dx, al
    
    call wait_controller
    
    mov dx, 0x3F5
    mov al, 0x00
    out dx, al
    
    call wait_controller
    
    mov dx, 0x3F5
    mov al, 0x02
    out dx, al
    
    call wait_controller
    
    mov dx, 0x3F5
    mov al, 0x12
    out dx, al
    
    call wait_controller
    
    mov dx, 0x3F5
    mov al, 0x1B
    out dx, al
    
    call wait_controller
    
    mov dx, 0x3F5
    mov al, 0xFF
    out dx, al
    
    lea eax, [msg_params_sent]
    push eax
    call printk
    add esp, 4
    
    lea eax, [msg_wait_irq]
    push eax
    call printk
    add esp, 4
    
wait_read_irq:
    cmp byte ptr [floppy_irq_fired], 0
    je wait_read_irq
    
    lea eax, [msg_irq_got]
    push eax
    call printk
    add esp, 4
    
    mov byte ptr [floppy_irq_fired], 0
    
    call wait_controller
    mov dx, 0x3F5
    in al, dx
    
    lea edi, [hex_buffer]
    movzx ebx, al
    shr ebx, 4
    and ebx, 0x0F
    lea edx, [hex_chars]
    add edx, ebx
    movzx ebx, byte ptr [edx]
    mov [edi], bl
    
    inc edi
    movzx ebx, al
    and ebx, 0x0F
    lea edx, [hex_chars]
    add edx, ebx
    movzx ebx, byte ptr [edx]
    mov [edi], bl
    
    inc edi
    mov byte ptr [edi], 0x00
    
    lea eax, [msg_st0]
    push eax
    call printk
    add esp, 4
    
    lea eax, [hex_buffer]
    push eax
    call printk
    add esp, 4
    
    lea eax, [newline]
    push eax
    call printk
    add esp, 4
    
    call wait_controller
    mov dx, 0x3F5
    in al, dx
    
    call wait_controller
    mov dx, 0x3F5
    in al, dx
    
    call wait_controller
    mov dx, 0x3F5
    in al, dx
    
    call wait_controller
    mov dx, 0x3F5
    in al, dx
    
    call wait_controller
    mov dx, 0x3F5
    in al, dx
    
    call wait_controller
    mov dx, 0x3F5
    in al, dx
    
    lea eax, [msg_results_read]
    push eax
    call printk
    add esp, 4
    
    movzx eax, byte ptr [0x1000]
    
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
    mov byte ptr [edi], 0x00
    
    lea eax, [msg_first_byte]
    push eax
    call printk
    add esp, 4
    
    lea eax, [hex_buffer]
    push eax
    call printk
    add esp, 4
    
    lea eax, [newline]
    push eax
    call printk
    add esp, 4
    
    lea eax, [msg_printing]
    push eax
    call printk
    add esp, 4
    
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
    
    lea eax, [msg_done]
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
msg_init:
    .asciz "Floppy init start\n"
msg_dma:
    .asciz "DMA setup done\n"
msg_idt:
    .asciz "IDT setup done\n"
msg_reset:
    .asciz "Resetting floppy\n"
msg_wait_reset:
    .asciz "Waiting for reset IRQ\n"
msg_irq1:
    .asciz "IRQ 1\n"
msg_specify:
    .asciz "Sending specify\n"
msg_reset_done:
    .asciz "Reset complete\n"
msg_ready:
    .asciz "Floppy ready\n"
msg_print_start:
    .asciz "print_bytes called\n"
msg_motor_on:
    .asciz "Motor on\n"
msg_cmd_sent:
    .asciz "Read command sent\n"
msg_params_sent:
    .asciz "Parameters sent\n"
msg_wait_irq:
    .asciz "Waiting for read IRQ\n"
msg_irq_got:
    .asciz "Read IRQ received\n"
msg_results_read:
    .asciz "Results read\n"
msg_printing:
    .asciz "Printing data:\n"
msg_done:
    .asciz "Done\n"
msg_st0:
    .asciz "ST0: "
msg_first_byte:
    .asciz "First byte at 0x1000: "
floppy_irq_fired:
    .byte 0

.section .bss
hex_buffer:
    .skip 4
