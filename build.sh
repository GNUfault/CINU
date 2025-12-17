#!/bin/sh
set -e

NASM=nasm
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

    NASM_VER=$($NASM -v)
    BUILD_DATE=$(date)

    cat > build_info.asm <<EOF
global nasm_version
global build_date

section .rodata
nasm_version db "${NASM_VER}", 0
build_date   db "${BUILD_DATE}", 0
EOF

    CFILES=$(find . -name "*.c")
    ASMFILES=$(find . -path ./src/boot -prune -o -name "*.asm" -print)

    for f in $CFILES; do
        o="$BUILD_DIR/$(basename "${f%.*}").o"
        gcc $CFLAGS -c "$f" -o "$o"
    done

    for f in $ASMFILES; do
        o="$BUILD_DIR/$(basename "${f%.*}").o"
        $NASM -f elf32 "$f" -o "$o"
    done

    KERNEL_OBJS=$(find "$BUILD_DIR" -maxdepth 1 -name "*.o")
    $LD $LDFLAGS -o "$KERNEL" $KERNEL_OBJS
    objcopy --strip-all "$KERNEL"

    USER_OBJS="$BUILD_DIR/init.o"
    $LD $USER_LDFLAGS -o "$USER" $USER_OBJS
    objcopy --strip-all "$USER"
  
    $NASM -f elf32 src/boot/boot.asm -o build/boot.o
    $LD -T src/boot/link.ld build/boot.o -o build/boot.bin
    cat build/boot.bin build/kernel.elf build/user.elf > cinux.img
    
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
