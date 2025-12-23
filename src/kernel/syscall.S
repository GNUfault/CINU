.intel_syntax noprefix
.code32

.global syscall_handler
.extern printk

.section .data
syscall_table:
    .long sys_print

.section .text

syscall_handler:
    pusha
    push ds
    push es
    push fs
    push gs

    mov ax, 0x10
    mov ds, ax
    mov es, ax

    cmp eax, 0
    jne sys_invalid

    mov eax, [syscall_table]
    call eax
    jmp sys_return

sys_invalid:
    jmp sys_return

sys_print:
    push ebx
    call printk
    add esp, 4
    ret

sys_return:
    pop gs
    pop fs
    pop es
    pop ds
    popa
    iretd
