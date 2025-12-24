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

.global speaker_init
.global speaker_tone
.extern printk

.equ PIT_CTRL, 0x43
.equ PIT_CH2, 0x42
.equ PORT_SPKR, 0x61
.equ PIT_BASE, 1193180

speaker_init:
    push eax

    push offset msg_init_speaker
    call printk
    add esp, 4

    in al, PORT_SPKR
    and al, 0xFC
    out PORT_SPKR, al
    pop eax
    ret

speaker_tone:
    push ebp
    mov  ebp, esp
    push eax
    push ebx
    push edx
    mov  ebx, [ebp+8]
    test ebx, ebx
    jz   tone_off
    mov  eax, PIT_BASE
    xor  edx, edx
    div  ebx
    test eax, eax
    jnz  tone_div_ok
    mov  eax, 1
tone_div_ok:
    mov al, 0xB6
    out PIT_CTRL, al
    mov edx, eax
    mov al, dl
    out PIT_CH2, al
    mov al, dh
    out PIT_CH2, al
    in al, PORT_SPKR
    or al, 0x03
    out PORT_SPKR, al
    jmp tone_done

tone_off:
    in al, PORT_SPKR
    and al, 0xFC
    out PORT_SPKR, al

tone_done:
    pop edx
    pop ebx
    pop eax
    mov esp, ebp
    pop ebp
    ret

.section .data
msg_init_speaker:
    .asciz "Initializing speaker...\n"
