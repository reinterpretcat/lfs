#!/bin/bash
set -e
echo "Building bash.."
echo "Approximate build time:  0.4 SBU"
echo "Required disk space: 61 MB"

# 5.16. Bash package contains the Bourne-Again SHell
tar -xf bash-*.tar.gz -C /tmp/ \
  && mv /tmp/bash-* /tmp/bash \
  && pushd /tmp/bash \
  && ./configure --prefix=/tools --without-bash-malloc \
  && make \
  && if [ $LFS_TEST -eq 1 ]; then make tests; fi \
  && make install \
  && ln -sv bash /tools/bin/sh \
  && popd \
  && rm -rf /tmp/bash
