/*
 * CINUX
 * Copyright (C) 2025 Connor Thomson
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "serial.h"
#include "io.h"

#define COM1 0x3F8

#define DATA_REG 0
#define INT_ENABLE_REG 1
#define FIFO_CTRL_REG 2
#define LINE_CTRL_REG 3
#define MODEM_CTRL_REG 4
#define LINE_STATUS_REG 5
#define MODEM_STATUS_REG 6

#define DLAB 0x80
#define INT_DATA_AVAILABLE 0x01

#define RX_BUFFER_SIZE 256
static char rx_buffer[RX_BUFFER_SIZE];
static volatile int rx_head = 0;
static volatile int rx_tail = 0;

void serial_irq_handler(void) {
    while (inb(COM1 + LINE_STATUS_REG) & 0x01) {
        char c = inb(COM1 + DATA_REG);
        int next = (rx_head + 1) % RX_BUFFER_SIZE;
        if (next != rx_tail) {
            rx_buffer[rx_head] = c;
            rx_head = next;
        }
    }
}

void serial_init(void) {
    outb(COM1 + INT_ENABLE_REG, 0x00);
    outb(COM1 + LINE_CTRL_REG, DLAB);
    outb(COM1 + DATA_REG, 0x03);
    outb(COM1 + INT_ENABLE_REG, 0x00);
    outb(COM1 + LINE_CTRL_REG, 0x03);
    outb(COM1 + FIFO_CTRL_REG, 0xC7);
    outb(COM1 + MODEM_CTRL_REG, 0x0B);
    outb(COM1 + INT_ENABLE_REG, INT_DATA_AVAILABLE);
}

int serial_transmit_empty(void) {
    return inb(COM1 + LINE_STATUS_REG) & 0x20;
}

void serial_putchar(char c) {
    while (!serial_transmit_empty());
    outb(COM1 + DATA_REG, c);
}

void serial_write(const char *str) {
    while (*str) {
        if (*str == '\n') {
            serial_putchar('\r');
        }
        serial_putchar(*str++);
    }
}

int serial_received(void) {
    return rx_head != rx_tail;
}

char serial_getchar(void) {
    while (!serial_received());
    char c = rx_buffer[rx_tail];
    rx_tail = (rx_tail + 1) % RX_BUFFER_SIZE;
    return c;
}
