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

#include "pmt.h"

#define STACK_SIZE 4096

static struct task task_list[MAX_TASKS];
static int current_task_index = 0;
static int total_tasks = 0;

// This is called by the PIT assembly stub
unsigned int pmt_schedule(unsigned int current_esp) {
    if (total_tasks < 2) return current_esp; // Don't switch if only 1 task

    // Save the stack pointer of the task that just paused
    task_list[current_task_index].esp = current_esp;

    // Pick the next task (Round Robin)
    current_task_index++;
    if (current_task_index >= total_tasks) {
        current_task_index = 0;
    }

    // Return the stack pointer of the new task
    return task_list[current_task_index].esp;
}

// This sets up a "fake" stack so the first switch works
void pmt_create_task(void (*entry_point)(void)) {
    // In a real OS, use a memory allocator. Here, we use a static buffer.
    static unsigned char task_stacks[MAX_TASKS][STACK_SIZE];
    
    unsigned int *stack = (unsigned int *)(task_stacks[total_tasks] + STACK_SIZE);

    // Push the values IRETD expects to find when we "return" to this task
    *(--stack) = 0x10; // SS (Data Segment)
    *(--stack) = (unsigned int)stack; // ESP
    *(--stack) = 0x0202; // EFLAGS (Interrupts enabled)
    *(--stack) = 0x08; // CS (Code Segment)
    *(--stack) = (unsigned int)entry_point; // EIP (Where to start)

    // Push dummy values for pushad (EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI)
    for(int i = 0; i < 8; i++) *(--stack) = 0;
    
    // Push segment registers
    *(--stack) = 0x10; // DS
    *(--stack) = 0x10; // ES
    *(--stack) = 0x10; // FS
    *(--stack) = 0x10; // GS

    task_list[total_tasks].esp = (unsigned int)stack;
    task_list[total_tasks].active = 1;
    total_tasks++;
}
