#include "vga.h"
#include "idt.h"
#include "cpu.h"
#include "gdt.h"
#include "rings.h"

extern void init(void);

void _start(void) {
  clear_screen();
  gdt_install();
  tss_install();
  idt_init();
  print("Kernel running in Ring 0!\n");  
  enter_user(USER_STACK_TOP, init);
  enter_kernel(KERNEL_STACK_TOP);
  print("Back in Ring 0\n");
  hlt();
}
