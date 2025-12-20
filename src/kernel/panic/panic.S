.intel_syntax noprefix
.global panic

panic:
    push ebp
    mov ebp, esp
    
    push dword ptr offset panic_msg
    call printk
    
    add esp, 4
    
    push dword ptr [ebp + 8]
    call printk
    
    add esp, 4
    
    hlt

.section .rodata
panic_msg:
    .asciz "PANIC: "
