.intel_syntax noprefix
.section .text
.global enable_paging
enable_paging:
    lea edi, [page_directory]
    lea eax, [page_table_0]
    or eax, 0x03
    mov ecx, 1024
fill_pd:
    stosd
    add eax, 0x1000
    loop fill_pd
    
    lea edi, [page_table_0]
    mov eax, 0x03
    mov ecx, 1048576
fill_pt:
    stosd
    add eax, 0x1000
    loop fill_pt
    
    lea eax, [page_directory]
    mov cr3, eax
 
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax
    
    ret

.section .bss
page_directory:
    .skip 4096

page_table_0:
    .skip 4194304
