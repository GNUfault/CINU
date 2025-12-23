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

.extern printk
.extern setup_idt
.extern serial_init
.extern pit_init
.extern keyboard_init
.extern speaker_init
.extern gdt_init
.extern build_time
.extern gas_ver
.extern user_mode
.extern tss_init
.extern load_user

.global _start

_start:
    push offset msg1
    call printk
    add esp, 4

    push offset gas_ver
    call printk
    add esp, 4

    push offset msg2
    call printk
    add esp, 4

    push offset build_time
    call printk
    add esp, 4

    push offset msg3
    call printk
    add esp, 4

    call gdt_init
    call idt_init
    sti
    call serial_init
    call pit_init
    call speaker_init
    call keyboard_init
    call tss_init

    call load_user
    call user_mode

.loop:
    hlt
    jmp .loop

.section .data
msg1:
    .asciz "CINUX (Built with: "
msg2:
    .asciz ") (Built on: "
msg3:
    .asciz ")\n"

