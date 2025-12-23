.intel_syntax noprefix

.global tss_entry
.global tss_init
.global flush_tss

.section .bss
.align 16
tss_entry:
    .space 104

.section .text

tss_init:
    mov ecx, 104
    mov edi, offset tss_entry
    xor eax, eax
    rep stosb
    mov eax, 0x00900000
    mov dword ptr [tss_entry + 4], eax
    mov eax, 0x10 
    mov dword ptr [tss_entry + 8], eax
    mov word ptr [tss_entry + 102], 104
    mov ax, (5 * 8)
    ltr ax
    ret
