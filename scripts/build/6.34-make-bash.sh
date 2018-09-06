#!/bin/bash
set -e
echo "Building bash"
echo "Approximate build time: 2.0 SBU"
echo "Required disk space: 56 MB"

# 6.34. Bash package contains the Bourne-Again SHell
tar -xf /sources/bash-*.tar.gz -C /tmp/ \
  && mv /tmp/bash-* /tmp/bash \
  && pushd /tmp/bash

# prepare bash
./configure --prefix=/usr               \
    --docdir=/usr/share/doc/bash-4.4.18 \
    --without-bash-malloc               \
    --with-installed-readline

# Compile the package
make

# Run tests
if [ $LFS_TEST -eq 1 ]
    then
    # To prepare the tests, ensure that the nobody user can write to the sources tree
    chown -Rv nobody .
    # Now, run the tests as the nobody user:
    su nobody -s /bin/bash -c "PATH=$PATH make tests"
fi

# Install the package and move the main executable to /bin
make install
mv -vf /usr/bin/bash /bin

# cleanup
popd \
  && rm -rf /tmp/bash
