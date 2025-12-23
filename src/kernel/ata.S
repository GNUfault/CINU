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

.global ata_init
.global read_bytes

.extern printk

.set ATA_PRIMARY_IO, 0x1F0
.set ATA_PRIMARY_CTRL, 0x3F6

.set ATA_REG_DATA, 0
.set ATA_REG_ERROR, 1
.set ATA_REG_SECCOUNT0, 2
.set ATA_REG_LBA0, 3
.set ATA_REG_LBA1, 4
.set ATA_REG_LBA2, 5
.set ATA_REG_HDDEVSEL, 6
.set ATA_REG_COMMAND, 7
.set ATA_REG_STATUS, 7

.set ATA_CMD_READ_PIO, 0x20
.set ATA_SR_BSY, 0x80
.set ATA_SR_DRQ, 0x08

.set BUF_BYTES, 1024
.set HEX_BYTES, (BUF_BYTES * 2 + 1)
.set STR_BYTES, (BUF_BYTES + 1)

.bss
.align 4
ata_raw_buf:
    .skip BUF_BYTES
ata_hex_buf:
    .skip HEX_BYTES
ata_str_buf:
    .skip STR_BYTES

.text

ata_delay400:
    push dx
    mov dx, ATA_PRIMARY_CTRL
    in al, dx
    in al, dx
    in al, dx
    in al, dx
    pop dx
    ret

ata_wait_busy_clear:
    push dx
1:
    mov dx, ATA_PRIMARY_IO + ATA_REG_STATUS
    in al, dx
    test al, ATA_SR_BSY
    jnz 1b
    pop dx
    ret

ata_wait_drq_set:
    push dx
2:
    mov dx, ATA_PRIMARY_IO + ATA_REG_STATUS
    in al, dx
    test al, ATA_SR_BSY
    jnz 2b
    test al, ATA_SR_DRQ
    jz 2b
    pop dx
    ret

ata_init:
    push eax
    push edx
    xor eax, eax
    mov edx, ATA_PRIMARY_CTRL
    out dx, al
    call ata_delay400
    pop edx
    pop eax
    ret

read_bytes:
    push ebp
    mov ebp, esp
    pushad

    mov edx, ATA_PRIMARY_IO + ATA_REG_HDDEVSEL
    mov al, 0xE0
    out dx, al

    call ata_delay400
    call ata_wait_busy_clear

    mov dx, ATA_PRIMARY_IO + ATA_REG_SECCOUNT0
    mov al, 2
    out dx, al

    mov dx, ATA_PRIMARY_IO + ATA_REG_LBA0
    mov al, 1
    out dx, al
    mov dx, ATA_PRIMARY_IO + ATA_REG_LBA1
    xor al, al
    out dx, al
    mov dx, ATA_PRIMARY_IO + ATA_REG_LBA2
    xor al, al
    out dx, al

    mov dx, ATA_PRIMARY_IO + ATA_REG_COMMAND
    mov al, ATA_CMD_READ_PIO
    out dx, al

    call ata_wait_drq_set

    mov edi, ata_raw_buf
    mov ecx, 256
    mov dx, ATA_PRIMARY_IO + ATA_REG_DATA
3:
    in ax, dx
    mov [edi], ax
    add edi, 2
    loop 3b

    call ata_wait_drq_set
    mov ecx, 256
4:
    in ax, dx
    mov [edi], ax
    add edi, 2
    loop 4b

    mov esi, ata_raw_buf
    mov edi, ata_hex_buf
    mov ecx, BUF_BYTES
5:
    mov al, [esi]
    push ecx
    mov bl, al
    shr bl, 4
    and bl, 0x0F
    mov bh, al
    and bh, 0x0F

    mov dl, bl
    cmp dl, 9
    jbe 6f
    add dl, 'A' - 10
    jmp 7f
6:
    add dl, '0'
7:
    mov [edi], dl
    inc edi

    mov dl, bh
    cmp dl, 9
    jbe 8f
    add dl, 'A' - 10
    jmp 9f
8:
    add dl, '0'
9:
    mov [edi], dl
    inc edi

    inc esi
    pop ecx
    loop 5b

    mov byte ptr [edi], 0

    mov esi, ata_raw_buf
    mov edi, ata_str_buf
    mov ecx, BUF_BYTES
10:
    mov al, [esi]
    cmp al, 0x20
    jb 11f
    cmp al, 0x7E
    ja 11f
    jmp 12f
11:
    mov al, '.'
12:
    mov [edi], al
    inc esi
    inc edi
    loop 10b
    mov byte ptr [edi], 0

    push ata_str_buf
    call printk
    add esp, 4

    push ata_hex_buf
    call printk
    add esp, 4

    popad
    mov esp, ebp
    pop ebp
    ret
