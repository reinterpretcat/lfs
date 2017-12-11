#!/bin/bash
set -e
echo "Configuring syslinux.."

# extract syslinux
tar -xf $LFS/sources/syslinux-*.tar.xz -C /tmp/
mv /tmp/syslinux-* /tmp/syslinux
# copy needed syslinux binaries
cp /tmp/syslinux/bios/core/isolinux.bin isolinux/isolinux.bin
cp /tmp/syslinux/bios/com32/elflink/ldlinux/ldlinux.c32 isolinux/ldlinux.c32
# cleanup
rm -rf /tmp/syslinux

cat > isolinux/isolinux.cfg << "EOF"
PROMT 0

DEFAULT arch

LABEL arch
    KERNEL vmlinuz
    APPEND initrd=ramdisk.img root=/dev/ram0 3
EOF
