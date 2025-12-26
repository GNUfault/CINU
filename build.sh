#!/bin/sh
#
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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

set -e

CC=clang
LD=ld.lld
AS=nasm
OBJCOPY=llvm-objcopy

BUILD_DIR=build
SRC_DIR=src

ISO_DIR="iso"
GRUB_DIR="$ISO_DIR/grub"
BOOT_DIR="$ISO_DIR/boot"

GRUB_CFG="$SRC_DIR/grub.cfg"

KERNEL="$BUILD_DIR/kernel.elf"
ISO=cinux.iso

CFLAGS="-m32 -std=c99 -ffreestanding -fno-pic -fno-pie -nostdlib -nostartfiles -Wall -Wextra -I$SRC_DIR"
LDFLAGS="-m elf_i386 -T $SRC_DIR/link.ld"

clean() {
    rm -rf "$BUILD_DIR" "$IMG"
}

all() {
    clean
    mkdir -p "$BUILD_DIR"

    BUILD_TIME=$(date)
    CLANG_VER=$(clang --version | head -n1)

    cat > "$BUILD_DIR/info.asm" <<EOF
section .rodata
global build_time
build_time:
    db "$BUILD_TIME", 0
global clang_ver
clang_ver:
    db "$CLANG_VER", 0
EOF

    ASMFILES=$(find "$SRC_DIR" -name "*.asm" ! -path "$BOOT_DIR/boot.asm")

    for f in $ASMFILES; do
        o="$BUILD_DIR/$(basename "${f%.*}").o"
        $AS -f elf32 "$f" -o "$o"
    done

    $AS -f elf32 "$BUILD_DIR/info.asm" -o "$BUILD_DIR/info.o"

    CFILES=$(find "$SRC_DIR" -name "*.c")

    for f in $CFILES; do
        o="$BUILD_DIR/$(basename "${f%.*}").o"
        $CC $CFLAGS -c "$f" -o "$o"
    done

    KERNEL_OBJS=$(find "$BUILD_DIR" -maxdepth 1 -name "*.o" ! -name "boot.o")
    $LD $LDFLAGS -o "$KERNEL" $KERNEL_OBJS
    $OBJCOPY --strip-all "$KERNEL"

    mkdir -p "$BOOT_DIR" "$GRUB_DIR"
    cp "$KERNEL" "$BOOT_DIR"
    cp "$GRUB_CFG" "$GRUB_DIR"

    grub-mkrescue "$ISO_DIR" -o "$ISO"
}

run() {
    qemu-system-i386 "$IMG"
}

case "$1" in
    "")
        all
        ;;
    all)
        all
        ;;
    run)
        run
        ;;
    clean)
        clean
        ;;
    *)
        echo "Usage: $0 {all|run|clean}"
        ;;
esac

