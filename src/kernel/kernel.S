.intel_syntax noprefix

.extern panic
.extern enable_paging

.section .rodata
msg:
    .asciz "Nothing else implemented (yet)\n"

.section .text
.global _start
_start:
    call enable_paging
    
    push offset msg
    call panic
