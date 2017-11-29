#!/bin/bash
set -e
echo "Building bash"
echo "Approximate build time: 2.0 SBU"
echo "Required disk space: 56 MB"

# 6.34. Bash package contains the Bourne-Again SHell
tar -xf /sources/bash-*.tar.gz -C /tmp/ \
  && mv /tmp/bash-* /tmp/bash \
  && pushd /tmp/bash
# incorporate some upstream fixes
patch -Np1 -i /sources/bash-4.4-upstream_fixes-1.patch
# prepare bash
./configure --prefix=/usr            \
    --docdir=/usr/share/doc/bash-4.4 \
    --without-bash-malloc            \
    --with-installed-readline
# compile
make
# ensure that the nobody user can write to the sources tree
chown -Rv nobody .
# run the tests as the nobody user
su nobody -s /bin/bash -c "PATH=$PATH make tests"
# install
make install
mv -vf /usr/bin/bash /bin
# cleanup
popd \
  && rm -rf /tmp/bash
