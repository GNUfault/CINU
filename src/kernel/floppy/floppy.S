.intel_syntax noprefix

.section .data
floppy_buffer: .skip 512
motor_ticks: .quad 0
current_track: .byte 0

.section .text
.globl floppy_init
.globl open
.globl read
.globl write
.globl close
.globl lseek

.equ DOR, 0x3F2
.equ MSR, 0x3F4
.equ FIFO, 0x3F5
.equ CCR, 0x3F7

.equ CMD_READ, 0xE6
.equ CMD_WRITE, 0xC5
.equ CMD_SEEK, 0x0F
.equ CMD_RECALIBRATE, 0x07
.equ CMD_SENSE_INT, 0x08
.equ CMD_SPECIFY, 0x03

floppy_init:
    push rbp
    mov rbp, rsp
    
    mov dx, DOR
    mov al, 0x00
    out dx, al
    
    mov dx, CCR
    mov al, 0x00
    out dx, al
    
    mov dx, DOR
    mov al, 0x0C
    out dx, al
    
    mov rdi, 500
    call sleep_ms
    
    call floppy_recalibrate
    
    pop rbp
    ret

open:
    push rbp
    mov rbp, rsp
    
    xor rax, rax
    
    pop rbp
    ret

close:
    push rbp
    mov rbp, rsp
    
    mov dx, DOR
    mov al, 0x0C
    out dx, al
    
    xor rax, rax
    
    pop rbp
    ret

lseek:
    push rbp
    mov rbp, rsp
    
    mov rax, rsi
    
    pop rbp
    ret

read:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    
    mov r12, rdi
    mov r13, rsi
    mov r14, rdx
    
    xor r15, r15
    
read_loop:
    cmp r15, r14
    jge read_done
    
    mov rax, r12
    add rax, r15
    xor rdx, rdx
    mov rcx, 512
    div rcx
    
    mov rdi, rax
    call floppy_read_sector
    
    cmp rax, 0
    jl read_error
    
    mov rdi, r13
    add rdi, r15
    lea rsi, [rip + floppy_buffer]
    mov rcx, 512
    mov rax, r14
    sub rax, r15
    cmp rax, 512
    jge copy_full
    mov rcx, rax
copy_full:
    rep movsb
    
    add r15, 512
    jmp read_loop
    
read_done:
    mov rax, r14
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
    
read_error:
    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

write:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    
    mov r12, rdi
    mov r13, rsi
    mov r14, rdx
    
    xor r15, r15
    
write_loop:
    cmp r15, r14
    jge write_done
    
    lea rdi, [rip + floppy_buffer]
    mov rsi, r13
    add rsi, r15
    mov rcx, 512
    mov rax, r14
    sub rax, r15
    cmp rax, 512
    jge copy_full_w
    mov rcx, rax
copy_full_w:
    rep movsb
    
    mov rax, r12
    add rax, r15
    xor rdx, rdx
    mov rcx, 512
    div rcx
    
    mov rdi, rax
    call floppy_write_sector
    
    cmp rax, 0
    jl write_error
    
    add r15, 512
    jmp write_loop
    
write_done:
    mov rax, r14
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
    
write_error:
    mov rax, -1
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

floppy_read_sector:
    push rbp
    mov rbp, rsp
    push r12
    
    mov r12, rdi
    
    mov rax, r12
    xor rdx, rdx
    mov rcx, 18
    div rcx
    mov r8, rax
    mov r9, rdx
    inc r9
    
    movzx rdi, r8b
    call floppy_seek
    
    call wait_floppy
    
    mov dx, FIFO
    mov al, CMD_READ
    out dx, al
    
    call wait_floppy
    xor al, al
    out dx, al
    
    call wait_floppy
    mov al, r8b
    out dx, al
    
    call wait_floppy
    xor al, al
    out dx, al
    
    call wait_floppy
    mov al, r9b
    out dx, al
    
    call wait_floppy
    mov al, 2
    out dx, al
    
    call wait_floppy
    mov al, 18
    out dx, al
    
    call wait_floppy
    mov al, 0x1B
    out dx, al
    
    call wait_floppy
    mov al, 0xFF
    out dx, al
    
    lea rdi, [rip + floppy_buffer]
    mov rcx, 512
read_data:
    call wait_floppy
    mov dx, FIFO
    in al, dx
    stosb
    loop read_data
    
    mov rcx, 7
read_status:
    call wait_floppy
    mov dx, FIFO
    in al, dx
    loop read_status
    
    xor rax, rax
    pop r12
    pop rbp
    ret

floppy_write_sector:
    push rbp
    mov rbp, rsp
    push r12
    
    mov r12, rdi
    
    mov rax, r12
    xor rdx, rdx
    mov rcx, 18
    div rcx
    mov r8, rax
    mov r9, rdx
    inc r9
    
    movzx rdi, r8b
    call floppy_seek
    
    call wait_floppy
    
    mov dx, FIFO
    mov al, CMD_WRITE
    out dx, al
    
    call wait_floppy
    xor al, al
    out dx, al
    
    call wait_floppy
    mov al, r8b
    out dx, al
    
    call wait_floppy
    xor al, al
    out dx, al
    
    call wait_floppy
    mov al, r9b
    out dx, al
    
    call wait_floppy
    mov al, 2
    out dx, al
    
    call wait_floppy
    mov al, 18
    out dx, al
    
    call wait_floppy
    mov al, 0x1B
    out dx, al
    
    call wait_floppy
    mov al, 0xFF
    out dx, al
    
    lea rsi, [rip + floppy_buffer]
    mov rcx, 512
write_data:
    call wait_floppy
    lodsb
    mov dx, FIFO
    out dx, al
    loop write_data
    
    mov rcx, 7
write_status:
    call wait_floppy
    mov dx, FIFO
    in al, dx
    loop write_status
    
    xor rax, rax
    pop r12
    pop rbp
    ret

floppy_seek:
    push rbp
    mov rbp, rsp
    push r12
    
    mov r12, rdi
    
    call wait_floppy
    
    mov dx, FIFO
    mov al, CMD_SEEK
    out dx, al
    
    call wait_floppy
    xor al, al
    out dx, al
    
    call wait_floppy
    mov al, r12b
    out dx, al
    
    call floppy_wait_irq
    
    call wait_floppy
    mov dx, FIFO
    mov al, CMD_SENSE_INT
    out dx, al
    
    call wait_floppy
    in al, dx
    
    call wait_floppy
    in al, dx
    
    pop r12
    pop rbp
    ret

floppy_recalibrate:
    push rbp
    mov rbp, rsp
    
    call wait_floppy
    
    mov dx, FIFO
    mov al, CMD_RECALIBRATE
    out dx, al
    
    call wait_floppy
    xor al, al
    out dx, al
    
    call floppy_wait_irq
    
    call wait_floppy
    mov dx, FIFO
    mov al, CMD_SENSE_INT
    out dx, al
    
    call wait_floppy
    in al, dx
    
    call wait_floppy
    in al, dx
    
    pop rbp
    ret

wait_floppy:
    push rbp
    mov rbp, rsp
    
wait_loop:
    mov dx, MSR
    in al, dx
    test al, 0x80
    jz wait_loop
    
    pop rbp
    ret

floppy_wait_irq:
    push rbp
    mov rbp, rsp
    
    mov rdi, 100
    call sleep_ms
    
    pop rbp
    ret

sleep_ms:
    push rbp
    mov rbp, rsp
    push rcx
    
    imul rdi, 1000000
    mov rcx, rdi
delay_loop:
    pause
    loop delay_loop
    
    pop rcx
    pop rbp
    ret

