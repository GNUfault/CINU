.intel_syntax noprefix
.global gdt_flush
.global tss_flush

gdt_flush:
    mov eax, DWORD PTR [esp+4]
    lgdt [eax]
    ret

tss_flush:
    mov ax, WORD PTR [esp+4]
    ltr ax
    ret
