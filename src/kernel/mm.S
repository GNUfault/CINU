.intel_syntax noprefix
.section .text
.global enable_paging

enable_paging:
    lea edi, [page_directory]
    mov eax, 0x00000083
    mov ecx, 1024
fill_pd:
    stosd
    add eax, 0x00400000
    loop fill_pd
    
    lea eax, [page_directory]
    mov cr3, eax
    
    mov eax, cr4
    or eax, 0x00000010
    mov cr4, eax
    
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax
    
    ret

.section .bss
.align 4096
page_directory:
    .skip 4096
