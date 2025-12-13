.intel_syntax noprefix
.global syscall_handler

syscall_handler:
    push rbp
    mov rbp, rsp
    
    lea rdi, [rip + syscall_msg]
    call print
    
    leave
    ret

.section .rodata
syscall_msg:
    .asciz "Hello, syscalls!"
