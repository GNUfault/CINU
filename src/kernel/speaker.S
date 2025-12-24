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

speaker_init:
    push eax

    push offset msg_init_speaker
    call printk
    add esp, 4

    in al, 0x61
    and al, 0xFC
    out 0x61, al

    pop eax
    ret

speaker_tone:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push edx

    mov ebx, [ebp+8]
    test ebx, ebx
    jz tone_off

    mov eax, 1193180
    xor edx, edx
    div ebx
    test eax, eax
    jnz tone_div_ok
    mov eax, 1

tone_div_ok:
    mov al, 0xB6
    out 0x43, al

    mov edx, eax
    mov al, dl
    out 0x42, al
    mov al, dh
    out 0x42, al

    in al, 0x61
    or al, 0x03
    out 0x61, al
    jmp tone_done

tone_off:
    in al, 0x61
    and al, 0xFC
    out 0x61, al

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
