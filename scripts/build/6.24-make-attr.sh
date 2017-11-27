#!/bin/bash
set -e
echo "Building attr.."
echo "Approximate build time: less than 0.3 SBU"
echo "Required disk space: 3.3 MB"

# 6.24. Attr package contains utilities to administer the extended
# attributes on filesystem objects
tar -xf sources/attr-*.tar.gz -C /tmp/ \
  && mv /tmp/attr-* /tmp/attr \
  && pushd /tmp/attr
# modify the documentation directory so that it is a versioned directory
sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
# prevent installation of manual pages that were already installed
# by the man pages package
sed -i -e "/SUBDIRS/s|man[25]||g" man/Makefile
# fix a problem in the test procedures caused by changes in perl-5.26
sed -i 's:{(:\\{(:' test/run
# configure, compile and install
./configure --prefix=/usr \
    --bindir=/bin \
    --disable-static \
  && make \
  && make -j1 tests root-tests \
  && make install install-dev install-lib
# adjust installation
chmod -v 755 /usr/lib/libattr.so
mv -v /usr/lib/libattr.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so
# cleanup
popd \
  && rm -rf /tmp/attr
