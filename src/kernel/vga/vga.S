.intel_syntax noprefix
.code32
.section .data
pixel_index: .long 0

.section .text
.global printk

printk:
    push ebp
    mov ebp, esp
    push esi
    push edi
    
    mov esi, [ebp + 8]
    mov edi, [0x5000]
    test edi, edi
    jz .done
    
    mov ecx, [pixel_index]
    shl ecx, 1
    add edi, ecx
    
.loop:
    lodsb
    test al, al
    jz .done
    
    movzx ebx, al
    mov ax, bx
    shl ax, 8
    or ax, bx
    
    mov word ptr [edi], ax
    add edi, 2
    
    inc dword ptr [pixel_index]
    jmp .loop
    
.done:
    pop edi
    pop esi
    pop ebp
    ret
