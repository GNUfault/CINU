/*
 * CINUX
 * Copyright (C) 2025-2026 Connor Thomson
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

#include "pit.h"
#include "pit_s.h"
#include "pic.h"
#include "io.h"
#include "cpu.h"
#include "idt.h"

static volatile unsigned int timer_ticks = 0;

void pit_init(void) {
    unsigned short divisor = 1193182 / PIT_HZ;

    // Register IDT gate for IRQ 0 (Vector 32)
    idt_set_gate(32, (unsigned int)irq0_stub, 0x08, 0x8E);
  
    // Program the PIT hardware
    outb(0x43, 0x36);
    outb(0x40, (unsigned char)(divisor & 0xFF));
    outb(0x40, (unsigned char)((divisor >> 8) & 0xFF));

    // Unmask IRQ0 on the PIC
    irq_clear_mask(0);
}

void pit_handler(void) {
    timer_ticks++;
}

unsigned int get_tick_count(void) {
    return timer_ticks;
}

void sleep(unsigned int ticks) {
    unsigned int start = timer_ticks;
    while (timer_ticks < start + ticks) {
        pause();
    }
}
