#!/bin/bash
set -e
echo "Building Attr.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 3.3 MB"

# 6.24. The Attr package contains utilities to administer the extended
# attributes on filesystem objects
tar -xf /sources/attr-*.tar.gz -C /tmp/ \
  && mv /tmp/attr-* /tmp/attr \
  && pushd /tmp/attr

# Modify the documentation directory so that it is a versioned directory:
sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in

# Prevent installation of manual pages that were already installed
# by the man pages package:
sed -i -e "/SUBDIRS/s|man[25]||g" man/Makefile

# Fix a problem in the test procedures caused by changes in perl-5.26:
sed -i 's:{(:\\{(:' test/run

# Prepare Attr for compilation:
./configure --prefix=/usr \
    --bindir=/bin \
    --disable-static

# Compile the package:
make

# To test the results, issue:
if [ $LFS_TEST -eq 1 ]; then make -j1 tests root-tests; fi

# Install the package:
make install install-dev install-lib
chmod -v 755 /usr/lib/libattr.so

# The shared library needs to be moved to /lib, and as a result the
# .so file in /usr/lib will need to be recreated:
mv -v /usr/lib/libattr.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so

# Cleanup
popd \
  && rm -rf /tmp/attr
