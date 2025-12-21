.intel_syntax noprefix

.section .data
ram_low: .long 0
ram_high: .long 0
ram_free: .long 0

.section .text
.global enable_paging
.global detect_ram_low
.global detect_ram_high
.global detect_ram_free

%define PAGE_DIR   0x90000
%define PAGE_TABLE 0x91000

enable_paging:
    mov edi, PAGE_DIR
    mov ecx, 1024
    xor eax, eax
    rep stosd

    mov edi, PAGE_TABLE
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

    mov eax, PAGE_TABLE
    or eax, 3
    mov [PAGE_DIR], eax

    mov eax, PAGE_DIR
    mov cr3, eax

    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax
    ret
