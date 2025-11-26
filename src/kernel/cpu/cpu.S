.intel_syntax noprefix

.section .text
.global hlt
.global cli
.global sti

hlt:
    hlt
    ret

cli:
    cli
    ret

sti:
    sti
    ret
