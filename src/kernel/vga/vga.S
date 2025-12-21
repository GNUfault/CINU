.intel_syntax noprefix
.equ PAGE_DIR, 0x90000
.equ PAGE_TABLE, 0x91000

.section .data
ram_low: .long 0
ram_high: .long 0
ram_free: .long 0

.section .text
.global enable_paging
.global detect_ram_low
.global detect_ram_high
.global detect_ram_free

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

detect_ram_free:
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    xor esi, esi
    xor edi, edi
    mov ebx, 0
    lea edi, [ram_free]
.next_free:
    mov eax, 0xE820
    mov ecx, 24
    mov edx, 0x534D4150
    int 0x15
    jc .done_free
    cmp byte ptr [esi+4], 1
    jne .skip_free
    add [edi], eax
.skip_free:
    test ebx, ebx
    jnz .next_free
.done_free:
    mov eax, [ram_free]
    ret
