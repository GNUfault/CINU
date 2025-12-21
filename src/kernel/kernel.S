.intel_syntax noprefix

.extern panic
.extern boot_logo
.extern idt_setup
.extern pit_setup
.extern update_logo

.section .rodata
msg:
    .asciz "Nothing else implemented (yet)\n"

.section .text
.global _start
_start:
    call idt_setup
    call pit_setup

    call boot_logo
    
    push offset msg
    call panic
.loop
    add dword ptr [logo_angle], 1
    call update_logo
    jmp .loop
