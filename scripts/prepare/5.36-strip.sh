#!/bin/bash
set -e
echo "Stripping.."

# stripping unneeded files to reduce LFS size
strip --strip-debug /tools/lib/* || true
/usr/bin/strip --strip-unneeded /tools/{,s}bin/* || true
rm -rf /tools/{,share}/{info,man,doc}
