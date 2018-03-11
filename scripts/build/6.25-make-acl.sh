#!/bin/bash
set -e
echo "Building Acl.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 4.9 MB"

# 6.25. The Acl package contains utilities to administer Access Control
# Lists, which are used to define more fine-grained discretionary access
# rights for files and directories
tar -xf /sources/acl-*.tar.gz -C /tmp/ \
  && mv /tmp/acl-* /tmp/acl \
  && pushd /tmp/acl

# Modify the documentation directory so that it is a versioned directory:
sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in

# Fix some broken tests:
sed -i "s:| sed.*::g" test/{sbits-restore,cp,misc}.test

# Fix a problem in the test procedures caused by changes in perl-5.26:
sed -i 's/{(/\\{(/' test/run

# Fix a bug that causes getfacl -e to segfault on overly long group name:
sed -i -e "/TABS-1;/a if (x > (TABS-1)) x = (TABS-1);" \
    libacl/__acl_to_any_text.c

# Prepare Acl for compilation:
./configure --prefix=/usr    \
    --bindir=/bin            \
    --disable-static         \
    --libexecdir=/usr/lib

# Compile the package:
make

# Install the package:
make install install-dev install-lib
chmod -v 755 /usr/lib/libacl.so

# The shared library needs to be moved to /lib, and as a result the
# .so file in /usr/lib will need to be recreated:
mv -v /usr/lib/libacl.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so

# Cleanup
popd \
  && rm -rf /tmp/acl
