.intel_syntax noprefix

.section .data
cursor_x: .long 0
cursor_y: .long 0
logo_center_x: .long 25
logo_center_y: .long 25

.section .bss
.global logo_angle
logo_angle: .long 0

.section .rodata
.global font8x16
font8x16:
.incbin "src/kernel/vga/font.bin"
logo_data:
.incbin "src/kernel/vga/logo.bgr"

sin_table:
.long 0,17,35,52,70,87,105,122,139,156,174,191,208,225,242,259
.long 276,292,309,326,342,358,375,391,407,423,438,454,469,485,500,515
.long 530,545,559,574,588,602,616,629,643,656,669,682,695,707,719,731
.long 743,755,766,777,788,799,809,819,829,839,848,857,866,875,883,891
.long 899,906,914,921,927,934,940,946,951,956,961,966,970,974,978,982
.long 985,988,990,993,995,997,999,1000
.long 1000,999,997,995,993,990,988,985,982,978,974,970,966,961,956,951
.long 946,940,934,927,921,914,906,899,891,883,875,866,857,848,839,829
.long 819,809,799,788,777,766,755,743,731,719,707,695,682,669,656,643
.long 629,616,602,588,574,559,545,530,515,500,485,469,454,438,423,407
.long 391,375,358,342,326,309,292,276,259,242,225,208,191,174,156,139
.long 122,105,87,70,52,35,17,0
.long -17,-35,-52,-70,-87,-105,-122,-139
.long -156,-174,-191,-208,-225,-242,-259,-276
.long -292,-309,-326,-342,-358,-375,-391,-407
.long -423,-438,-454,-469,-485,-500,-515,-530
.long -545,-559,-574,-588,-602,-616,-629,-643
.long -656,-669,-682,-695,-707,-719,-731,-743
.long -755,-766,-777,-788,-799,-809,-819,-829
.long -839,-848,-857,-866,-875,-883,-891,-899
.long -906,-914,-921,-927,-934,-940,-946,-951
.long -956,-961,-966,-970,-974,-978,-982,-985
.long -988,-990,-993,-995,-997,-999,-1000

.section .text
.global boot_logo
.global update_logo

boot_logo:
    call update_logo
    ret

update_logo:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    mov eax, [logo_angle]
    and eax, 255
    mov ebx, eax
    add eax, 64
    and eax, 255
    mov ecx, eax

    lea esi, [sin_table]
    mov eax, [esi + ebx*4]
    mov edx, [esi + ecx*4]
    mov [ebp-4], eax
    mov [ebp-8], edx

    xor ebx, ebx
row_loop:
    xor ecx, ecx
col_loop:
    mov eax, ecx
    sub eax, 25
    mov esi, eax

    mov eax, ebx
    sub eax, 25
    mov edi, eax

    mov eax, esi
    imul dword ptr [ebp-8]
    mov esi, eax

    mov eax, edi
    imul dword ptr [ebp-4]
    sub esi, eax

    mov eax, esi
    cdq
    mov edi, 1000
    idiv edi
    add eax, 25
    mov esi, eax

    mov eax, edi
    imul dword ptr [ebp-8]
    mov edx, eax

    mov eax, esi
    sub eax, 25
    imul dword ptr [ebp-4]
    add edx, eax

    mov eax, edx
    cdq
    mov edi, 1000
    idiv edi
    add eax, 25
    mov edi, eax

    test esi, esi
    js skip_px
    cmp esi, 50
    jge skip_px
    test edi, edi
    js skip_px
    cmp edi, 50
    jge skip_px

    mov eax, edi
    imul eax, 50
    add eax, esi
    lea esi, [eax + eax*2]
    add esi, logo_data

    mov eax, ebx
    imul eax, 1024
    add eax, ecx
    lea eax, [eax + eax*2]
    mov edi, [0x5000]
    add edi, 974*3
    add edi, eax

    mov al, [esi]
    mov dl, [esi+1]
    mov dh, [esi+2]
    mov [edi], al
    mov [edi+1], dl
    mov [edi+2], dh

skip_px:
    inc ecx
    cmp ecx, 50
    jl col_loop
    inc ebx
    cmp ebx, 50
    jl row_loop

    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
