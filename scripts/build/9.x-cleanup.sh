#!/bin/bash
set -e
echo "Cleanup.."

# unmount VFS
umount -v $LFS/dev/pts
umount -v $LFS/dev
umount -v $LFS/run
umount -v $LFS/proc
umount -v $LFS/sys

# unmount LFS
umount -v $LFS
