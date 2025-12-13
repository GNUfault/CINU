#include "vga.h"
#include "idt.h"
#include "cpu.h"
#include "gdt.h"
#include "info.h"
#include "panic.h"

extern void init(void);

void _start(void) {
  clear_screen();
  gdt_install();
  tss_install();
  idt_init();

  // We need printf()
  print("CINUX compiled with ");
  print(CC);
  print(" and assembled with ");
  print(AS);
  print(" on ");
  print(BUILD_DATE);
  print(" at ");
  print(BUILD_TIME);
  print(" on ");
  print(HOST);
  print("/n");

  // Panic for now
  panic("Nothing else implemented (yet)/n");
}
