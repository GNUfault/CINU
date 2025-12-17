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

    INCLUDES=$(find . -type d -exec echo -I{} \;)
    CFLAGS="-m32 -march=i486 -mtune=i486 -ffreestanding -Ofast -Wall -Wextra -fno-stack-protector -fno-builtin-strcpy -fno-builtin-strncpy $INCLUDES"
    LDFLAGS="-m elf_i386 -T src/kernel/link.ld"
    USER_LDFLAGS="-m elf_i386 -T src/user/link.ld"

    GAS_VER=$(as --version | head -n1)
    BUILD_DATE=$(date)

    cat > build_info.S <<EOF
.intel_syntax noprefix
.section .rodata
.global gas_version
.global build_date

gas_version:
    .asciz "${GAS_VER}"

build_date:
    .asciz "${BUILD_DATE}"
EOF

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
    objcopy --strip-all "$KERNEL"

    USER_OBJS="$BUILD_DIR/init.o"
    $LD $USER_LDFLAGS -o "$USER" $USER_OBJS
    objcopy --strip-all "$USER"
  
    # Quick and dirty, please fix me soon
    as --32 src/boot/boot.S -o build/boot.o
    ld -T src/boot/link.ld build/boot.o -o build/boot.bin
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
