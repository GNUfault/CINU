.intel_syntax noprefix

.extern printk
.extern setup_idt
.extern serial_init
.extern pit_init
.extern keyboard_init
.extern speaker_init
.extern gdt_init
.extern build_time
.extern gas_ver

.global _start

_start:
    push offset msg1
    call printk
    add esp, 4

    push offset gas_ver
    call printk
    add esp, 4

    push offset msg2
    call printk
    add esp, 4

    push offset build_time
    call printk
    add esp, 4

    push offset msg3
    call printk
    add esp, 4

    call gdt_init
    call idt_init
    sti
    call serial_init
    call pit_init
    call speaker_init
    call keyboard_init
.loop:
    hlt
    jmp .loop

.section .data
msg1:
    .asciz "CINUX (Built with: "
msg2:
    .asciz ") (Built on: "
msg3:
    .asciz ")\n"

