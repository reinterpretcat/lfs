#!/bin/bash
set -e
echo "Start building iso.."

# loop device
LOOP=/dev/loop2
# inital ram disk size in KB
IMAGE_SIZE="700000"
# location of initrd tree
INITRD_TREE=$LFS
# output image
IMAGE=isolinux/ramdisk.img

# extract syslinux
tar -xf /sources/syslinux-*.tar.xz -C /tmp/
mv /tmp/syslinux-* /tmp/syslinux
# copy needed syslinux binaries
cp /tmp/syslinux/bios/core/isolinux.bin isolinux/isolinux.bin
cp /tmp/syslinux/bios/com32/elflink/ldlinux/ldlinux.c32 isolinux/ldlinux.c32

# move kernel to isolinux folder
mv $LFS/boot/vmlinuz-* isolinux/vmlinuz

# create ramdisk file of IMAGE_SIZE
dd if=/dev/zero of=ramdisk bs=1k count=$IMAGE_SIZE
# associate it with ${LOOP}
losetup ${LOOP} ramdisk

# make an ext2 filesystem
mke2fs -q -i 16384 -m 0 ${LOOP} IMAGE_SIZE

# make sure we have loop2 directory
[ -d  loop2 ] || mkdir  loop2

# mount it
mount ${LOOP} loop2
rm -rf loop2/lost+found

# copy the contents of our initrdtree to this filesystem
cp -dpR INITRD_TREE/* loop2/

df loop2

# and unmount and divorce ${LOOP}
umount loop2
losetup -d ${LOOP}

# delete any existing one
rm -f $IMAGE
echo -n "Compressing system ramdisk image.... "
bzip2 -c ramdisk > $IMAGE
# cleanup
rm -f ramdisk

#### build iso
echo -n "Creating bootable iso.... "
mkisofs -o lfs.iso                \
        -b isolinux/isolinux.bin  \
        -c isolinux/boot.cat      \
        -no-emul-boot             \
        -boot-load-size 4         \
        -boot-info-table CD_root
echo "done"
