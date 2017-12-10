#!/bin/bash
set -e
echo "Start building bootable image.."
. /tools/.variables

sh /tools/1.configure-syslinux.sh
sh /tools/2.create-ramdisk.sh
sh /tools/3.build-iso.sh
