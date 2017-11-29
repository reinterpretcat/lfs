#!/bin/bash
set -e
echo "Building xml parser.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 2.0 MB"

# 6.41.XML::Parser module is a Perl interface to James Clark's XML parser, Expat
tar -xf /sources/XML-Parser-*.tar.gz -C /tmp/ \
  && mv /tmp/XML-Parser-* /tmp/XML-Parser \
  && pushd /tmp/XML-Parser
perl Makefile.PL
make
if [ $LFS_TEST -eq 1 ]; then make test; fi
make install
# cleanup
popd \
  && rm -rf /tmp/XML-Parser
