.intel_syntax noprefix
.section .data
pit_ticks: .long 0

.section .text
.global pit_setup
.global pit_on
.global pit_off
.global pit_ticks

.set PIT_CHANNEL0, 0x40
.set PIT_COMMAND, 0x43
.set PIT_DIVISOR, 1193

pit_setup:
    push ebp
    mov ebp, esp
    push eax
    
    mov al, 0x36
    out PIT_COMMAND, al
    
    mov ax, PIT_DIVISOR
    out PIT_CHANNEL0, al
    mov al, ah
    out PIT_CHANNEL0, al
    
    pop eax
    pop ebp
    ret

pit_on:
    push ebp
    mov ebp, esp
    push eax
    
    in al, 0x21
    and al, 0xFE
    out 0x21, al
    
    pop eax
    pop ebp
    ret

pit_off:
    push ebp
    mov ebp, esp
    push eax
    
    in al, 0x21
    or al, 0x01
    out 0x21, al
    
    pop eax
    pop ebp
    ret
