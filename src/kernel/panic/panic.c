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
    
    call hlt
    
    leave
    ret

.section .rodata
panic_msg:
    .asciz "PANIC: "
