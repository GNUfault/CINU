#!/bin/sh
set -e

NASM=nasm
LD=ld

BUILD_DIR=build

KERNEL="$BUILD_DIR/kernel.elf"
USER="$BUILD_DIR/user.elf"

clean() {
    echo "Cleaning build artifacts..."
    rm -rf "$BUILD_DIR" "$ISO"
}

all() {
    clean

    echo "Creating $BUILD_DIR directory..."
    mkdir -p "$BUILD_DIR"

    LDFLAGS="-T src/kernel/link.ld"
    USER_LDFLAGS="-T src/user/link.ld"

    echo "Generating build_info.asm..."

    NASM_VER=$($NASM -v)
    BUILD_DATE=$(date)

    cat > build_info.asm <<EOF
global nasm_version
global build_date

section .rodata
nasm_version db "${NASM_VER}", 0
build_date   db "${BUILD_DATE}", 0
EOF

    echo "Searching for assembly files to be assembled..."
    ASMFILES=$(find . -path ./src/boot -prune -o -name "*.asm" -print)

    for f in $ASMFILES; do
        o="$BUILD_DIR/$(basename "${f%.*}").o"
        echo "Assembling $(basename $f)..."
        $NASM -f elf32 "$f" -o "$o"
    done

    echo "Searching for kernel objects to be linked..."
    KERNEL_OBJS=$(find "$BUILD_DIR" -maxdepth 1 -name "*.o")
    echo "Linking $(basename -a $KERNEL_OBJS | xargs)..."
    $LD $LDFLAGS -o "$KERNEL" $KERNEL_OBJS

    echo "Searching for user objects to be linked..." 
    USER_OBJS="$BUILD_DIR/init.o"
    echo "Linking $(basename -a $USER_OBJS | xargs)..."
    $LD $USER_LDFLAGS -o "$USER" $USER_OBJS

    echo "Assembling boot.asm..."
    $NASM -f bin src/boot/boot.asm -o build/boot.bin
   
    echo "Creating cinux.img..."
    cat build/boot.bin build/kernel.bin build/user.bin > cinux.img
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
