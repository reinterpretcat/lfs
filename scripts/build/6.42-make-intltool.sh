#!/bin/bash
set -e
echo "Building intltool.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 1.5 MB"

# 6.42. Intltool is an internationalization tool used for extracting
# translatable strings from source files
tar -xf /sources/intltool-*.tar.gz -C /tmp/ \
  && mv /tmp/intltool-* /tmp/intltool \
  && pushd /tmp/intltool
# fix a warning that is caused by perl-5.22 and later
sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make
if [ $LFS_TEST -eq 1 ]; then make check; fi
make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
# cleanup
popd \
  && rm -rf /tmp/intltool
