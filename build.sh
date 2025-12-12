#!/bin/sh
set -e

CC=gcc
AS=as
LD=ld

BUILD_DIR=build
ISO_DIR="$BUILD_DIR/iso"
BOOT_DIR="$ISO_DIR/boot"
GRUB_DIR="$BOOT_DIR/grub"

KERNEL="$BUILD_DIR/kernel.elf"
USER="$BUILD_DIR/user.elf"
ISO="cdos.iso"
GRUB_CFG=src/boot/grub.cfg

clean() {
    rm -rf "$BUILD_DIR" "$ISO"
}

all() {
    clean
    mkdir -p "$BUILD_DIR"

    {
        echo "#ifndef INFO_H"
        echo "#define INFO_H"
        echo "#define CC \"$($CC --version | awk 'NR==1 {print $1, $3}')\""
        echo "#define AS \"$(as --version | head -n 1 | sed 's/ *(.*)//g')\""
        echo "#define HOST \"$(uname -sr)\""
        echo "#define BUILD_TIME __TIME__"
        echo "#define BUILD_DATE __DATE__"
        echo "#endif"
    } > "$BUILD_DIR/info.h"

    INCLUDES=$(find . -type d -exec echo -I{} \;)
    CFLAGS="-m32 -march=i486 -mtune=i486 -ffreestanding -Ofast -Wall -Wextra -fno-stack-protector -fno-builtin-strcpy -fno-builtin-strncpy $INCLUDES"
    LDFLAGS="-m elf_i386 -T src/kernel/link.ld"
    USER_LDFLAGS="-m elf_i386 -T src/user/link.ld"

    CFILES=$(find . -name "*.c")
    SFILES=$(find . -path ./src/boot -prune -o -name "*.S" -print)

    for f in $CFILES; do
        o="$BUILD_DIR/$(basename "${f%.*}").o"
        $CC $CFLAGS -c "$f" -o "$o"
    done

    for f in $SFILES; do
        o="$BUILD_DIR/$(basename "${f%.*}").o"
        $AS --32 "$f" -o "$o"
    done

    KERNEL_OBJS=$(find "$BUILD_DIR" -maxdepth 1 -name "*.o")
    $LD $LDFLAGS -o "$KERNEL" $KERNEL_OBJS
    objdump --strip-all "$KERNEL"

    USER_OBJS="$BUILD_DIR/init.o"
    $LD $USER_LDFLAGS -o "$USER" $USER_OBJS
    objdump --strip-all "$USER"
  
    # Quick and dirty, please fix me soon
    as --32 src/boot/boot.S -o build/boot.o
    ld -m elf_i386 build/boot.bin build/boot.o
    cat build/boot.bin build/kernel.elf build/user.elf >> cinux.img
    
    rm -rf "$BUILD_DIR"
}

run() {
    qemu-system-i386 -drive file="$ISO",media=cdrom,if=ide
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
