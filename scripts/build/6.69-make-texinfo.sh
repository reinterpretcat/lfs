#!/bin/bash
set -e
echo "Building texinfo.."
echo "Approximate build time: 1.1 SBU"
echo "Required disk space: 128 MB"

# 6.69. Texinfo package contains programs for reading, writing,
# and converting info pages
tar -xf /sources/texinfo-*.tar.xz -C /tmp/ \
  && mv /tmp/texinfo-* /tmp/texinfo \
  && pushd /tmp/texinfo

./configure --prefix=/usr --disable-static
make
if [ $LFS_TEST -eq 1 ]; then make check; fi
make install
make TEXMF=/usr/share/texmf install-tex
# fix package out of sync with the info pages installed on the system
pushd /usr/share/info
rm -v dir
for f in *
  do install-info $f dir 2>/dev/null
done
popd
# cleanup
popd \
  && rm -rf /tmp/texinfo
