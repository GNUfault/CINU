.intel_syntax noprefix

.global speaker_init
.global speaker_tone

.equ PIT_CTRL, 0x43
.equ PIT_CH2, 0x42
.equ PORT_SPKR, 0x61
.equ PIT_BASE, 1193180

speaker_init:
    push eax
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
