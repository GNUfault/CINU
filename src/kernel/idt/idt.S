.intel_syntax noprefix

.extern isr0, isr1, isr2, isr3, isr4, isr5, isr6, isr7
.extern isr8, isr9, isr10, isr11, isr12, isr13, isr14, isr15
.extern isr16, isr17, isr18, isr19, isr20, isr21, isr22, isr23
.extern isr24, isr25, isr26, isr27, isr28, isr29, isr30, isr31
.extern irq0, irq1, irq2, irq3, irq4, irq5, irq6, irq7
.extern irq8, irq9, irq10, irq11, irq12, irq13, irq14, irq15
.extern isr128

.section .bss
.align 4
.global idt
idt:
    .skip 2048

.global idt_reg
idt_reg:
    .skip 6

.section .text

.global idt_set_gate
.type idt_set_gate, @function
idt_set_gate:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    
    movzx eax, byte ptr [ebp + 8]
    mov ebx, eax
    shl ebx, 3
    lea esi, [idt + ebx]
    
    mov edx, [ebp + 12]
    mov word ptr [esi], dx
    
    mov cx, word ptr [ebp + 16]
    mov word ptr [esi + 2], cx
    
    mov byte ptr [esi + 4], 0
    
    mov dl, byte ptr [ebp + 20]
    mov byte ptr [esi + 5], dl
    
    mov edx, [ebp + 12]
    shr edx, 16
    mov word ptr [esi + 6], dx
    
    pop esi
    pop ebx
    pop ebp
    ret

.global idt_init
.type idt_init, @function
idt_init:
    push ebp
    mov ebp, esp
    
    lea eax, [idt]
    mov dword ptr [idt_reg + 2], eax
    mov word ptr [idt_reg], 2047
    
    push 0x8E
    push 0x08
    push offset isr0
    push 0
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr1
    push 1
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr2
    push 2
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr3
    push 3
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr4
    push 4
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr5
    push 5
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr6
    push 6
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr7
    push 7
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr8
    push 8
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr9
    push 9
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr10
    push 10
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr11
    push 11
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr12
    push 12
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr13
    push 13
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr14
    push 14
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr15
    push 15
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr16
    push 16
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr17
    push 17
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr18
    push 18
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr19
    push 19
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr20
    push 20
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr21
    push 21
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr22
    push 22
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr23
    push 23
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr24
    push 24
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr25
    push 25
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr26
    push 26
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr27
    push 27
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr28
    push 28
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr29
    push 29
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr30
    push 30
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset isr31
    push 31
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset irq0
    push 32
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset irq1
    push 33
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset irq2
    push 34
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset irq3
    push 35
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset irq4
    push 36
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset irq5
    push 37
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset irq6
    push 38
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset irq7
    push 39
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset irq8
    push 40
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset irq9
    push 41
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset irq10
    push 42
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset irq11
    push 43
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset irq12
    push 44
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset irq13
    push 45
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset irq14
    push 46
    call idt_set_gate
    add esp, 16
    
    push 0x8E
    push 0x08
    push offset irq15
    push 47
    call idt_set_gate
    add esp, 16
    
    push 0xEE
    push 0x08
    push offset isr128
    push 0x80
    call idt_set_gate
    add esp, 16
    
    lea eax, [idt_reg]
    push eax
    call idt_load
    add esp, 4
    
    pop ebp
    ret

.global idt_load
.type idt_load, @function
idt_load:
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    lidt [eax]
    pop ebp
    ret
