#ifndef RING_H
#define RING_H

#define KERNEL_STACK_TOP 0x90000
#define USER_STACK_TOP   0x80000

extern void enter_user(unsigned int user_stack, void (*user_func)(void));
extern void enter_kernel(unsigned int kernel_stack);

#endif
