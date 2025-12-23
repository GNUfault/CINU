.intel_syntax noprefix

.global ata_load
.global ata_init

.extern printk

.set ATA_PRIMARY_IO, 0x1F0
.set ATA_PRIMARY_CTRL, 0x3F6

.set ATA_REG_DATA, 0
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

ata_load:
    push ebp
    mov ebp, esp
    pushad

    mov eax, [ebp+8]
    mov ebx, [ebp+12]
    mov edi, [ebp+16]

3:
    cmp eax, ebx
    ja 9f

    mov edx, ATA_PRIMARY_IO + ATA_REG_HDDEVSEL
    mov al, 0xE0
    out dx, al

    call ata_delay400
    call ata_wait_busy_clear

    mov dx, ATA_PRIMARY_IO + ATA_REG_SECCOUNT0
    mov al, 1
    out dx, al

    mov ecx, eax
    mov dx, ATA_PRIMARY_IO + ATA_REG_LBA0
    mov al, cl
    out dx, al
    mov dx, ATA_PRIMARY_IO + ATA_REG_LBA1
    mov al, ch
    out dx, al
    shr ecx, 16
    mov dx, ATA_PRIMARY_IO + ATA_REG_LBA2
    mov al, cl
    out dx, al

    mov dx, ATA_PRIMARY_IO + ATA_REG_COMMAND
    mov al, ATA_CMD_READ_PIO
    out dx, al

    call ata_wait_drq_set

    mov dx, ATA_PRIMARY_IO + ATA_REG_DATA
    mov ecx, 256
4:
    in ax, dx
    mov [edi], ax
    add edi, 2
    loop 4b

    inc eax
    jmp 3b

9:
    popad
    mov esp, ebp
    pop ebp
    ret
