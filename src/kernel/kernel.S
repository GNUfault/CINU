.intel_syntax noprefix
.global _start

.extern clear_screen
.extern gdt_install
.extern tss_install
.extern idt_init
.extern print
.extern panic

_start:
    call clear_screen
    
    call gdt_install
    
    call tss_install
    
    call idt_init
    
    push offset string_panic_msg
    call panic
    add esp, 4

.section .rodata
string_panic_msg:
    .asciz "Nothing else implemented (yet)\n"
