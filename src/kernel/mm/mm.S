.intel_syntax noprefix

.section .bss
.align 4096
page_directory:
    .space 4096
.align 4096
first_page_table:
    .space 4096

.section .bss
ram_low:  .long 0
ram_high: .long 0

.section .text
.global enable_paging
.global detect_ram_low
.global detect_ram_high

enable_paging:
    xor eax, eax
    mov ecx, 1024
.fill_table:
    mov ebx, eax
    or ebx, 3
    mov [first_page_table + eax], ebx
    add eax, 4
    loop .fill_table

    mov eax, first_page_table
    or eax, 3
    mov [page_directory], eax

    mov eax, page_directory
    mov cr3, eax

    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    ret

detect_ram_low:
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    xor esi, esi
    xor edi, edi

    mov ebx, 0
    lea edi, [ram_low]
.next_low:
    mov eax, 0xE820
    mov ecx, 24
    mov edx, 0x534D4150
    int 0x15
    jc .done_low
    cmp byte ptr [esi+4], 1
    jne .skip_low
    cmp eax, 0xA0000
    ja .skip_low
    add [edi], eax
.skip_low:
    test ebx, ebx
    jnz .next_low
.done_low:
    mov eax, [ram_low]
    ret

detect_ram_high:
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    xor esi, esi
    xor edi, edi

    mov ebx, 0
    lea edi, [ram_high]
.next_high:
    mov eax, 0xE820
    mov ecx, 24
    mov edx, 0x534D4150
    int 0x15
    jc .done_high
    cmp byte ptr [esi+4], 1
    jne .skip_high
    cmp eax, 0x100000
    jb .skip_high
    add [edi], eax
.skip_high:
    test ebx, ebx
    jnz .next_high
.done_high:
    mov eax, [ram_high]
    ret
