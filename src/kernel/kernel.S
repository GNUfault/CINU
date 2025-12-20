.intel_syntax noprefix

.extern panic
.extern printk
.extern detect_ram_low
.extern detect_ram_high
.extern detect_ram_free

.section .rodata
mem_msg:
    .asciz "Total memory: "
free_msg:
    .asciz "KB, Free memory: "
end_msg:
    .asciz "KB\n"
msg:
    .asciz "Nothing else implemented (yet)\n"

.section .text
.global _start
_start:
    call detect_ram_low
    mov ebx, eax
    call detect_ram_high
    add ebx, eax
    mov esi, ebx
    shr esi, 10
    push esi
    mov esi, mem_msg
    call printk
    add esp, 4

    call detect_ram_free
    shr eax, 10
    push eax
    mov esi, free_msg
    call printk
    add esp, 4

    mov esi, end_msg
    call printk

    push offset msg
    call panic
