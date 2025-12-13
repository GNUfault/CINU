#include "vga.h"
#include "cpu.h"

void panic(const char* string) {
    print("PANIC: ");
    print(string);
    hlt();
}
