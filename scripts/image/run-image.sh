#!/bin/bash
set -e
echo "Start building bootable image.."

sh /tools/1.configure-syslinux.sh
sh /tools/2.create-ramdisk.sh
sh /tools/3.build-iso.sh
