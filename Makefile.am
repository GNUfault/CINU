# CINUX
# Copyright (C) 2025 Connor Thomson
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

bin_PROGRAMS    = cinux.elf

cinux_elf_SOURCES  = boot.s main.c vga.c cpu.s io.s

LINKER_SCRIPT = link.ld

cinux_elf_CFLAGS    = -m32 -march=i386 -mtune=i386 -Ofast -ffreestanding -Wall -Wextra -fno-stack-protector -fno-builtin -nostdinc -std=c99 -pedantic -pedantic-errors -fno-common -fno-pie -fno-pic
cinux_elf_CCASFLAGS = -m32
cinux_elf_LDFLAGS   = -nostdlib -T $(LINKER_SCRIPT)

ISO_DIR  = iso
GRUB_CFG = grub.cfg
KERNEL   = cinux.elf
FONT     = font.bin
BOOT_DIR = $(ISO_DIR)/boot
GRUB_DIR = $(BOOT_DIR)/grub

QEMU = qemu-system-i386

all: $(ISO)

if USE_GRUB

$(ISO):
	mkdir -p $(GRUB_DIR)
	cp $(GRUB_CFG) $(GRUB_DIR)
	cp $(KERNEL) $(ISO_DIR)
	grub-mkrescue --install-modules="normal multiboot" -o $(ISO) $(ISO_DIR)

endif

run:
	$(QEMU) $(ISO)

clean:
	rm -rf $(CLEANFILES)

CLEANFILES = $(KERNEL) $(ISO) $(ISO_DIR)
