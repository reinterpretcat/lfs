#!/bin/bash
set -e
echo -n "Building bootable iso.... "

# copy kernel to isolinux folder
cp $LFS/boot/vmlinuz-* isolinux/vmlinuz

# build iso
genisoimage -o lfs.iso                \
            -b isolinux/isolinux.bin  \
            -c isolinux/boot.cat      \
            -no-emul-boot             \
            -boot-load-size 4         \
            -boot-info-table CD_root

echo "Your image is located: $(pwd)/lfs.iso"
