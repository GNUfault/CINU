    .globl gdt_flush
gdt_flush:
    movl 4(%esp), %eax
    lgdt (%eax)
    ret
