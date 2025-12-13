.intel_syntax noprefix
.global panic

panic:
    push rbp
    mov rbp, rsp
    push rdi

    lea rdi, [rip + panic_msg]
    call print
    
    pop rdi
    call print
    
    hlt

.section .rodata
panic_msg:
    .asciz "PANIC: "
