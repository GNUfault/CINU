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
    call serial_init

    push offset m_pit
    call printk
    add esp, 4
    call pit_init

    push offset m_speaker
    call printk
    add esp, 4
    call speaker_init

    push offset m_keyboard
    call printk
    add esp, 4
    call keyboard_init

    push offset m_tss
    call printk
    add esp, 4
    call tss_init

    push offset m_user
    call printk
    add esp, 4
    call user_mode

.section .data
msg1:
    .asciz "CINUX (Built with: "
msg2:
    .asciz ") (Built on: "
msg3:
    .asciz ")\n"

m_gdt:
    .asciz "Initializing GDT...\n"
m_idt:
    .asciz "Initializing IDT...\n"
m_serial:
    .asciz "Initializing Serial...\n"
m_pit:
    .asciz "Initializing PIT...\n"
m_speaker:
    .asciz "Initializing Speaker...\n"
m_keyboard:
    .asciz "Initializing Keyboard...\n"
m_tss:
    .asciz "Initializing TSS...\n"
m_user:
    .asciz "Entering ring 3...\n"
