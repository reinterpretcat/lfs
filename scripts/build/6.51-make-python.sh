#!/bin/bash
set -e
echo "Building Python.."
echo "Approximate build time: 1.2 SBU"
echo "Required disk space: 354 MB"

# 6.51. The Python 3 package contains the Python development environment. It is useful
# for object-oriented programming, writing scripts, prototyping large programs or
# developing entire applications.
tar -xf /sources/Python-*.tar.gz -C /tmp/ \
  && mv /tmp/Python-* /tmp/python \
  && pushd /tmp/python
# prepare for compilation
./configure --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --with-ensurepip=yes
# compile, test and install
make
# install tool
make install
chmod -v 755 /usr/lib/libpython3.6m.so
chmod -v 755 /usr/lib/libpython3.so

# install the documentation
if [ $LFS_DOCS -eq 1 ]; then
    # Install documentation
    install -v -dm755 /usr/share/doc/python-3.6.4/html
    # Extract archive
    tar --strip-components=1  \
        --no-same-owner       \
        --no-same-permissions \
        -C /usr/share/doc/python-3.6.4/html \
        -xvf /sources/python-3.6.4-docs-html.tar.bz2
fi

# cleanup
popd \
  && rm -rf /tmp/python
