.intel_syntax noprefix

.section .bss
.align 4
cursor_pos:
    .long 0

.section .text
.global printk

printk:
    push ebp
    mov ebp, esp
    mov esi, [ebp + 8]
    mov edi, [cursor_pos]
    shl edi, 1
    add edi, 0xB8000
.loop:
    lodsb
    test al, al
    jz .done
    cmp al, 10
    jne .char
    mov eax, [cursor_pos]
    mov edx, 0
    mov ecx, 80
    div ecx
    inc eax
    mul ecx
    mov [cursor_pos], eax
    mov edi, eax
    shl edi, 1
    add edi, 0xB8000
    jmp .loop
.char:
    mov [edi], al
    mov byte ptr [edi + 1], 0x07
    add edi, 2
    inc dword ptr [cursor_pos]
    jmp .loop
.done:
    pop ebp
    ret
