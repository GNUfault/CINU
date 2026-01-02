# CINUX
# Copyright (C) 2025-2026 Connor Thomson
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

bin_PROGRAMS = cinux.elf boot.bin

cinux_elf_SOURCES  = main.c vga.c cpu.s io.s gdt.c gdt_s.s idt.c idt_s.s pic.c
boot_bin_SOURCES   = boot.s

cinux_elf_LINKER_SCRIPT = link.ld
boot_bin_LINKER_SCRIPT  = boot.ld

cinux_elf_CFLAGS    = -m32 -march=i386 -mtune=i386 -Ofast -ffreestanding -Wall -Wextra -fno-stack-protector -fno-builtin -nostdinc -std=c99 -pedantic -pedantic-errors -fno-common -fno-pie -fno-pic
cinux_elf_CCASFLAGS = -m32
cinux_elf_LDFLAGS   = -nostdlib -T $(cinux_elf_LINKER_SCRIPT)
boot_bin_CCASFLAGS  = -m32
boot_bin_LDFLAGS    = -nostdlib -T $(boot_bin_LINKER_SCRIPT)

BOOTLOADER = boot.bin
KERNEL     = cinux.elf

QEMU = qemu-system-i386

all: $(FLOPPY)

$(FLOPPY):
	cat $(BOOTLOADER) $(KERNEL) >> $(FLOPPY)

# I made this as fast as possible and this needs fixing
run:
	$(QEMU) $(ISO)

clean:
	rm -rf $(CLEANFILES)

CLEANFILES = $(KERNEL) $(ISO) $(ISO_DIR)
