.intel_syntax noprefix
.equ PAGE_DIR, 0x90000
.equ PAGE_TABLE, 0x91000

.section .text
.global enable_paging

enable_paging:
    lea edi, [PAGE_DIR]
    mov ecx, 1024
    xor eax, eax
    rep stosd
    lea edi, [PAGE_TABLE]
    mov ecx, 1024
    xor eax, eax
    rep stosd
    xor eax, eax
    mov ecx, 1024
.fill_pt:
    mov ebx, eax
    shl ebx, 12
    or ebx, 3
    mov [PAGE_TABLE + eax*4], ebx
    inc eax
    loop .fill_pt
    lea eax, [PAGE_TABLE]
    or eax, 3
    mov [PAGE_DIR], eax
    lea eax, [PAGE_DIR]
    mov cr3, eax
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax
    ret
