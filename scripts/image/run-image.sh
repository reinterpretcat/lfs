#!/bin/bash
set -e
echo "Start building bootable image.."

pushd /tmp
mkdir -p isolinux

sh /tools/1.configure-syslinux.sh
sh /tools/2.create-ramdisk.sh
sh /tools/3.build-iso.sh

rm -rf isolinux
popd
