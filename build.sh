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

AS=as
LD=ld

AS_FLAGS="--32"

BUILD_DIR=build
SRC_DIR=src

KERNEL="$BUILD_DIR/kernel.elf"
USER="$BUILD_DIR/user.elf"

IMG=cinux.img

BOOT_DIR=$SRC_DIR/boot

clean() {
    rm -rf "$BUILD_DIR" "$IMG"
}

all() {
    clean
    mkdir -p "$BUILD_DIR"

    LDFLAGS="-m elf_i386 -T src/kernel/link.ld"
    USER_LDFLAGS="-m elf_i386 -T src/user/link.ld"

    BUILD_TIME=$(date)
    GAS_VER=$(as -version | grep -oE "[0-9]+\.[0-9]+" | head -n1)

    cat > info.S <<EOF
.section .rodata
.global build_time
build_time:
.asciz "$BUILD_TIME"
.global gas_ver
gas_ver:
.asciz "GAS $GAS_VER"
EOF

    SFILES=$(find . -path ./src/boot -prune -o -name "*.S" -print)

    for f in $SFILES; do
        o="$BUILD_DIR/$(basename "${f%.*}").o"
        $AS $AS_FLAGS "$f" -o "$o"
    done

    KERNEL_OBJS=$(find "$BUILD_DIR" -maxdepth 1 -name "*.o")
    $LD $LDFLAGS -o "$KERNEL" $KERNEL_OBJS
    objcopy --strip-all "$KERNEL"

    USER_OBJS="$BUILD_DIR/init.o"
    $LD $USER_LDFLAGS -o "$USER" $USER_OBJS
    objcopy --strip-all "$USER"

    $AS $AS_FLAGS $BOOT_DIR/stage1.S -o $BUILD_DIR/stage1.o
    $LD -T $BOOT_DIR/stage1.ld $BUILD_DIR/stage1.o -o $BUILD_DIR/stage1.bin

    $AS $AS_FLAGS $BOOT_DIR/stage2.S -o $BUILD_DIR/stage2.o
    $LD -T $BOOT_DIR/stage2.ld $BUILD_DIR/stage2.o -o $BUILD_DIR/stage2.bin
    
    cat $BUILD_DIR/stage1.bin $BUILD_DIR/stage2.bin $BUILD_DIR/kernel.elf $BUILD_DIR/user.elf >> $IMG
}

run() {
    qemu-system-i386 cinux.img
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
