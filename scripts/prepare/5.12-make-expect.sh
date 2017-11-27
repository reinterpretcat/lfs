#!/bin/bash
set -e
echo "Building expect.."
echo "Approximate build time: 0.1 SBU"
echo "Required disk space: 4.3 MB"

# 5.12. Expect package contains a program for carrying out scripted
# dialogues with other interactive programs
tar -xf expect*.tar.gz -C /tmp/ \
  && mv /tmp/expect* /tmp/expect \
  && pushd /tmp/expect \
  && cp -v configure{,.orig} \
  && sed 's:/usr/local/bin:/bin:' configure.orig > configure \
  && ./configure --prefix=/tools        \
      --with-tcl=/tools/lib            \
      --with-tclinclude=/tools/include \
  && make \
  && if [ $LFS_TEST -eq 1 ]; then make test; fi \
  && make SCRIPTS="" install \
  && popd \
  && rm -rf /tmp/expect
