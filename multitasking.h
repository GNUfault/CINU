/*
 * CINUX
 * Copyright (C) 2025-2026 Connor Thomson
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

#ifndef PMT_H
#define PMT_H

struct task {
    unsigned int esp; // Current stack pointer (top of saved context)
    unsigned int stack_base; // Base address of the allocated stack memory
    unsigned int id; // Unique Task ID
    int active; // 1 if running/ready, 0 if empty slot
};

void pmt_init(void);
void pmt_create_task(void (*entry_point)(void));
unsigned int pmt_schedule(unsigned int current_esp);

#endif
