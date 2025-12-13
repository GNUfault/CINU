.intel_syntax noprefix

.global idt_load

.global isr0, isr1, isr2, isr3, isr4, isr5, isr6, isr7
.global isr8, isr9, isr10, isr11, isr12, isr13, isr14, isr15
.global isr16, isr17, isr18, isr19, isr20, isr21, isr22, isr23
.global isr24, isr25, isr26, isr27, isr28, isr29, isr30, isr31

.global irq0, irq1, irq2, irq3, irq4, irq5, irq6, irq7
.global irq8, irq9, irq10, irq11, irq12, irq13, irq14, irq15

.extern isr_handler
.extern irq_handler

.macro ISR n
.global isr\n
isr\n:
    push 0
    push \n
    jmp common_isr
.endm

.macro ISR_ERR n
.global isr\n
isr\n:
    push \n
    jmp common_isr
.endm

ISR 0
ISR 1
ISR 2
ISR 3
ISR 4
ISR 5
ISR 6
ISR 7
ISR_ERR 8
ISR 9
ISR_ERR 10
ISR_ERR 11
ISR_ERR 12
ISR_ERR 13
ISR_ERR 14
ISR 15
ISR 16
ISR 17
ISR 18
ISR 19
ISR 20
ISR 21
ISR 22
ISR 23
ISR 24
ISR 25
ISR 26
ISR 27
ISR 28
ISR 29
ISR_ERR 30
ISR 31

.macro IRQ n
.global irq\n
irq\n:
    push 0
    push (\n + 32)
    jmp common_irq
.endm

IRQ 0
IRQ 1
IRQ 2
IRQ 3
IRQ 4
IRQ 5
IRQ 6
IRQ 7
IRQ 8
IRQ 9
IRQ 10
IRQ 11
IRQ 12
IRQ 13
IRQ 14
IRQ 15

common_isr:
    pusha
    mov eax, esp
    push eax
    call isr_handler
    add esp, 4
    popa
    add esp, 8
    iretd

common_irq:
    pusha
    mov eax, esp
    push eax
    call irq_handler
    add esp, 4
    popa
    add esp, 8
    iretd
