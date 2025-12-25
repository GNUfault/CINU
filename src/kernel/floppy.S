.intel_syntax noprefix

.extern idt
.extern printk

.global floppy_init
.global floppy_read

.section .data

msg_init_begin:
    .asciz "Initializing floppy...\n"
msg_init_reset:
    .asciz "Resetting controller...\n"
msg_init_specify:
    .asciz "Specifying timing...\n"
msg_init_motor:
    .asciz "Turning motor on...\n"
msg_init_cal:
    .asciz "Calibrating drive...\n"
msg_init_irq:
    .asciz "Installing IRQ6 handler...\n"
msg_init_unmask:      
    .asciz "Unmasking IRQ6...\n"
msg_read_begin:
    .asciz "Starting floppy read...\n"
msg_read_dma:
    .asciz "Setting up DMA...\n"
msg_read_cmd:
    .asciz "Sending read command...\n"
msg_read_wait:    
    .asciz "Waiting for IRQ6...\n"
msg_read_irq:
    .asciz "IRQ6 received!\n"
msg_read_result:     
    .asciz "Reading result bytes...\n"
msg_irq_fired:       
    .asciz "IRQ6 fired!\n"

.section .bss
.align 4
floppy_irq_flag:
    .long 0

.section .text

fl_wait_rqm:
    in al, 0x3F4
    test al, 0x80
    jz fl_wait_rqm
    ret

fl_send:
    call fl_wait_rqm
    mov dx, 0x3F5
    out dx, al
    ret

fl_recv:
    call fl_wait_rqm
    mov dx, 0x3F5
    in al, dx
    ret

fl_reset:
    mov dx, 0x3F2
    mov al, 0x00
    out dx, al
    mov al, 0x0C
    out dx, al
    ret

fl_specify:
    mov al, 0x03
    call fl_send
    mov al, 0x0D
    call fl_send
    ret

fl_motor_on:
    mov dx, 0x3F2
    mov al, 0x1C
    out dx, al
    ret

fl_calibrate:
cal_loop:
    mov al, 0x07
    call fl_send
    mov al, 0x00
    call fl_send
cal_wait:
    in al, 0x3F4
    test al, 0x80
    jz cal_wait
    call fl_recv
    call fl_recv
    cmp al, 0x00
    jne cal_loop
    ret

floppy_init:
    pushad

    push offset msg_init_begin
    call printk
    add esp, 4

    call fl_reset
    push offset msg_init_reset
    call printk
    add esp, 4

    call fl_specify
    push offset msg_init_specify
    call printk
    add esp, 4

    call fl_motor_on
    push offset msg_init_motor
    call printk
    add esp, 4

    call fl_calibrate
    push offset msg_init_cal
    call printk
    add esp, 4

    push offset msg_init_irq
    call printk
    add esp, 4

    mov eax, floppy_irq_handler
    mov edx, 0x0008008E
    mov ebx, 0x26
    shl ebx, 3
    add ebx, idt
    mov [ebx], ax
    shr eax, 16
    mov [ebx+6], ax
    mov [ebx+2], dx

    push offset msg_init_unmask
    call printk
    add esp, 4

    in al, 0x21
    and al, 0xBF
    out 0x21, al

    popad
    ret

floppy_irq_handler:
    pushad

    mov dword ptr [floppy_irq_flag], 1

    push offset msg_irq_fired
    call printk
    add esp, 4

    mov al, 0x20
    out 0x20, al

    popad
    iretd

fl_dma_setup:
    mov ebx, eax
    mov al, bl
    out 0x0C, al
    out 0x04, al
    mov al, bh
    out 0x04, al
    shr ebx, 16
    mov al, bl
    out 0x81, al
    mov ax, cx
    shl ax, 9
    dec ax
    mov al, al
    out 0x05, al
    mov al, ah
    out 0x05, al
    ret

floppy_read:
    pushad

    push offset msg_read_begin
    call printk
    add esp, 4

    mov dword ptr [floppy_irq_flag], 0

    mov al, 0x14
    out 0x08, al

    mov al, 0x56
    out 0x0B, al

    call fl_dma_setup
    push offset msg_read_dma
    call printk
    add esp, 4

    mov al, 0x02
    out 0x0A, al

    mov al, 0x10
    out 0x08, al

    mov al, 0x46
    call fl_send
    mov al, 0x00
    call fl_send
    mov al, ch
    call fl_send
    mov al, dh
    call fl_send
    mov al, cl
    call fl_send
    mov al, 0x02
    call fl_send
    mov al, 0x1B
    call fl_send
    mov al, 0xFF
    call fl_send

    push offset msg_read_cmd
    call printk
    add esp, 4

    push offset msg_read_wait
    call printk
    add esp, 4

    sti

wait_irq6:
    cmp dword ptr [floppy_irq_flag], 0
    je wait_irq6

    cli

    push offset msg_read_irq
    call printk
    add esp, 4

    mov ecx, 7
res_loop:
    call fl_recv
    loop res_loop

    push offset msg_read_result
    call printk
    add esp, 4

    popad
    ret
