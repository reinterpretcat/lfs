#!/bin/bash
set -e
echo -n "Building bootable iso.... "

# move kernel to isolinux folder
mv $LFS/boot/vmlinuz-* isolinux/vmlinuz

# build iso
mkisofs -o lfs.iso                \
        -b isolinux/isolinux.bin  \
        -c isolinux/boot.cat      \
        -no-emul-boot             \
        -boot-load-size 4         \
        -boot-info-table CD_root

echo "Image built in $(pwd)"
