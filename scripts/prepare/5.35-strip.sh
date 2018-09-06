#!/bin/bash
set -e
echo "Stripping.."

# The steps in this section are optional, but if the LFS partition is rather
# small, it is beneficial to learn that unnecessary items can be removed.
# The executables and libraries built so far contain about 70 MB of unneeded
# debugging symbols. Remove those symbols with:
strip --strip-debug /tools/lib/* || true
/usr/bin/strip --strip-unneeded /tools/{,s}bin/* || true

# To save more, remove the documentation:
rm -rf /tools/{,share}/{info,man,doc}

# Remove unneeded files:
find /tools/{lib,libexec} -name \*.la -delete
