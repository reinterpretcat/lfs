#!/bin/bash
set -e
echo "Download toolchain.."


echo "Getting wget-list.."
wget --quiet --timestamping http://www.linuxfromscratch.org/lfs/view/8.1-systemd/wget-list

echo "Getting packages.."
wget --quiet --timestamping --directory-prefix=$LFS/sources --continue --input-file=wget-list

echo "Getting md5.."
wget --quiet --timestamping http://www.linuxfromscratch.org/lfs/downloads/8.1/md5sums

echo "Check hashes.."
pushd $LFS/sources
md5sum -c md5sums
popd
