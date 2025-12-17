.intel_syntax noprefix

.section .data
floppy_buffer: .skip 512
motor_ticks: .long 0
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
    push ebp
    mov ebp, esp
    
    mov dx, DOR
    mov al, 0x00
    out dx, al
    
    mov dx, CCR
    mov al, 0x00
    out dx, al
    
    mov dx, DOR
    mov al, 0x0C
    out dx, al
    
    push 500
    call sleep_ms
    add esp, 4
    
    call floppy_recalibrate
    
    pop ebp
    ret

open:
    push ebp
    mov ebp, esp
    
    xor eax, eax
    
    pop ebp
    ret

close:
    push ebp
    mov ebp, esp
    
    mov dx, DOR
    mov al, 0x0C
    out dx, al
    
    xor eax, eax
    
    pop ebp
    ret

lseek:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+12]
    
    pop ebp
    ret

read:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov ebx, [ebp+8]
    mov esi, [ebp+12]
    mov edi, [ebp+16]
    
    xor ecx, ecx
    
read_loop:
    cmp ecx, edi
    jge read_done
    
    mov eax, ebx
    add eax, ecx
    xor edx, edx
    mov ebx, 512
    div ebx
    
    push eax
    call floppy_read_sector
    add esp, 4
    
    cmp eax, 0
    jl read_error
    
    mov edi, esi
    add edi, ecx
    mov esi, offset floppy_buffer
    mov ecx, 512
    mov eax, [ebp+16]
    sub eax, ecx
    cmp eax, 512
    jge copy_full
    mov ecx, eax
copy_full:
    push ecx
    rep movsb
    pop ecx
    
    add ecx, 512
    mov ebx, [ebp+8]
    mov esi, [ebp+12]
    mov edi, [ebp+16]
    jmp read_loop
    
read_done:
    mov eax, [ebp+16]
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
    
read_error:
    mov eax, -1
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

write:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov ebx, [ebp+8]
    mov esi, [ebp+12]
    mov edi, [ebp+16]
    
    xor ecx, ecx
    
write_loop:
    cmp ecx, edi
    jge write_done
    
    mov edi, offset floppy_buffer
    mov esi, [ebp+12]
    add esi, ecx
    mov ecx, 512
    mov eax, [ebp+16]
    sub eax, ecx
    cmp eax, 512
    jge copy_full_w
    mov ecx, eax
copy_full_w:
    push ecx
    rep movsb
    pop ecx
    
    mov eax, ebx
    add eax, ecx
    xor edx, edx
    mov ebx, 512
    div ebx
    
    push eax
    call floppy_write_sector
    add esp, 4
    
    cmp eax, 0
    jl write_error
    
    add ecx, 512
    mov ebx, [ebp+8]
    mov esi, [ebp+12]
    mov edi, [ebp+16]
    jmp write_loop
    
write_done:
    mov eax, [ebp+16]
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
    
write_error:
    mov eax, -1
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

floppy_read_sector:
    push ebp
    mov ebp, esp
    push ebx
    
    mov ebx, [ebp+8]
    
    mov eax, ebx
    xor edx, edx
    mov ecx, 18
    div ecx
    mov ebx, eax
    mov ecx, edx
    inc ecx
    
    movzx eax, bl
    push eax
    call floppy_seek
    add esp, 4
    
    call wait_floppy
    
    mov dx, FIFO
    mov al, CMD_READ
    out dx, al
    
    call wait_floppy
    xor al, al
    out dx, al
    
    call wait_floppy
    mov al, bl
    out dx, al
    
    call wait_floppy
    xor al, al
    out dx, al
    
    call wait_floppy
    mov al, cl
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
    
    mov edi, offset floppy_buffer
    mov ecx, 512
read_data:
    call wait_floppy
    mov dx, FIFO
    in al, dx
    stosb
    loop read_data
    
    mov ecx, 7
read_status:
    call wait_floppy
    mov dx, FIFO
    in al, dx
    loop read_status
    
    xor eax, eax
    pop ebx
    pop ebp
    ret

floppy_write_sector:
    push ebp
    mov ebp, esp
    push ebx
    
    mov ebx, [ebp+8]
    
    mov eax, ebx
    xor edx, edx
    mov ecx, 18
    div ecx
    mov ebx, eax
    mov ecx, edx
    inc ecx
    
    movzx eax, bl
    push eax
    call floppy_seek
    add esp, 4
    
    call wait_floppy
    
    mov dx, FIFO
    mov al, CMD_WRITE
    out dx, al
    
    call wait_floppy
    xor al, al
    out dx, al
    
    call wait_floppy
    mov al, bl
    out dx, al
    
    call wait_floppy
    xor al, al
    out dx, al
    
    call wait_floppy
    mov al, cl
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
    
    mov esi, offset floppy_buffer
    mov ecx, 512
write_data:
    call wait_floppy
    lodsb
    mov dx, FIFO
    out dx, al
    loop write_data
    
    mov ecx, 7
write_status:
    call wait_floppy
    mov dx, FIFO
    in al, dx
    loop write_status
    
    xor eax, eax
    pop ebx
    pop ebp
    ret

floppy_seek:
    push ebp
    mov ebp, esp
    push ebx
    
    mov ebx, [ebp+8]
    
    call wait_floppy
    
    mov dx, FIFO
    mov al, CMD_SEEK
    out dx, al
    
    call wait_floppy
    xor al, al
    out dx, al
    
    call wait_floppy
    mov al, bl
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
    
    pop ebx
    pop ebp
    ret

floppy_recalibrate:
    push ebp
    mov ebp, esp
    
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
    
    pop ebp
    ret

wait_floppy:
    push ebp
    mov ebp, esp
    
wait_loop:
    mov dx, MSR
    in al, dx
    test al, 0x80
    jz wait_loop
    
    pop ebp
    ret

floppy_wait_irq:
    push ebp
    mov ebp, esp
    
    push 100
    call sleep_ms
    add esp, 4
    
    pop ebp
    ret

sleep_ms:
    push ebp
    mov ebp, esp
    push ecx
    
    mov eax, [ebp+8]
    imul eax, 1000000
    mov ecx, eax
delay_loop:
    pause
    loop delay_loop
    
    pop ecx
    pop ebp
    ret
