.intel_syntax noprefix
.global _start

.extern clear_screen
.extern gdt_install
.extern tss_install
.extern idt_init
.extern print
.extern panic
.extern CC
.extern AS
.extern BUILD_DATE
.extern BUILD_TIME
.extern HOST

_start:
    call clear_screen
    
    call gdt_install
    
    call tss_install
    
    call idt_init

    push offset string_cinux_compiled
    call print
    add esp, 4
    
    push offset CC
    call print
    add esp, 4
    
    push offset string_and_assembled
    call print
    add esp, 4
    
    push offset AS
    call print
    add esp, 4
    
    push offset string_on_date
    call print
    add esp, 4
    
    push offset BUILD_DATE
    call print
    add esp, 4
    
    push offset string_at_time
    call print
    add esp, 4
    
    push offset BUILD_TIME
    call print
    add esp, 4

    push offset string_on_host
    call print
    add esp, 4
    
    push offset HOST
    call print
    add esp, 4
    
    push offset string_newlines
    call print
    add esp, 4
    
    push offset string_panic_msg
    call panic
    add esp, 4

.section .rodata
string_cinux_compiled:
    .asciz "CINUX compiled with "
string_and_assembled:
    .asciz " and assembled with "
string_on_date:
    .asciz " on "
string_at_time:
    .asciz " at "
string_on_host:
    .asciz " on "
string_newlines:
    .asciz "\n\n"
string_panic_msg:
    .asciz "Nothing else implemented (yet)\n"
  
