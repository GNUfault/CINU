/*
 * CINUX
 * Copyright (C) 2025 Connor Thomson
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

.intel_syntax noprefix

.extern idt

.global ata_init
.global ata_read_lba

.section .bss
.align 4
ata_drq_flag:
    .byte 0

.section .text
.code32

ata_init:
    pushad
    mov eax, ata_irq_handler
    mov edx, 0x0008
    lea edi, [idt + 0x2E*8]
    mov word ptr [edi], ax
    shr eax, 16
    mov word ptr [edi+6], ax
    mov word ptr [edi+2], dx
    mov byte ptr [edi+4], 0
    mov byte ptr [edi+5], 0x8E
    popad
    ret

ata_read_lba:
    pushad
    mov edi, [esp+36]
  
# debug
mov al, 0xFE
out 0x64, al

    mov ebx, [esp+40]
    mov ecx, [esp+44]

.next_sector:
    mov byte ptr [ata_drq_flag], 0
    call ata_busy_clear

    mov dx, 0x1F2
    mov al, 1
    out dx, al
    inc dx
    mov eax, ebx
    mov al, bl
    out dx, al
    inc dx
    mov al, bh
    out dx, al
    inc dx
    shr eax, 16
    mov al, al
    out dx, al
    inc dx
    mov al, 0xE0
    out dx, al

    mov dx, 0x1F7
    mov al, 0x20
    out dx, al

.wait_irq:
    sti
    cmp byte ptr [ata_drq_flag], 1
    jne .hlt_wait
    cli

    mov dx, 0x1F0
    mov esi, 256

.read:
    in ax, dx
    mov [edi], ax
    add edi, 2
    dec esi
    jnz .read

    inc ebx
    dec ecx
    jnz .next_sector

    popad
    ret

.hlt_wait:
    hlt
    jmp .wait_irq

ata_busy_clear:
    mov dx, 0x1F7
.busy:
    in al, dx
    test al, 0x80
    jnz .busy
    ret

ata_irq_handler:
    pushad
    mov dx, 0x1F7
    in al, dx
    mov byte ptr [ata_drq_flag], 1
    mov al, 0x20
    mov dx, 0xA0
    out dx, al
    mov dx, 0x20
    out dx, al
    popad
    iretd
