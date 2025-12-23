#!/bin/sh
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

    $AS $AS_FLAGS $BOOT_DIR/boot.S -o $BUILD_DIR/boot.o
    $LD -T link.ld $BUILD_DIR/boot.o -o $BUILD_DIR/boot.bin
    cat $BUILD_DIR/boot.bin $BUILD_DIR/kernel.elf $BUILD_DIR/user.elf >> $IMG
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
