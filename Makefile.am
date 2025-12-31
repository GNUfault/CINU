# CINUX
# Copyright (C) 2025 Connor Thomson
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

bin_PROGRAMS = cinux.elf

cinux_elf_SOURCES = boot.s

cinux_elf_CFLAGS    = -ffreestanding -Wall -Wextra -fno-stack-protector -fno-builtin -nostdinc -std=c99 -pedantic -pedantic-errors -fno-common -fno-pie -fno-pic
cinux_elf_CCASFLAGS = -m32
cinux_elf_LDFLAGS   = -m32

ISO_DIR  = iso
GRUB_CFG = grub.cfg
KERNEL   = cinux.elf

all: iso

iso:
	mkdir -p $(ISO_DIR)
	cp $(GRUB_CFG) $(ISO_DIR)
	grub-mkrescue -o $(ISO) $(ISO_DIR)

CLEANFILES = $(KERNEL) $(ISO) $(ISO_DIR
