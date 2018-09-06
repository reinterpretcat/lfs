#!/bin/bash
set -e
echo "Cleaning up.."

# 6.80. Cleaning Up

# workaround for https://github.com/moby/moby/issues/13451
pushd /tmp/
for i in $(ls -d */); do
  while [[ -e  ${i%%/}/confdir3/confdir3 ]]; do
    mv confdir3/confdir3 confdir3a; rmdir confdir3; mv confdir3a confdir3;
  done;
done;
popd
rm -rf /tmp/*

# cleanup leftovers
rm -rf /usr/lib/lib{bfd,opcodes}.a
rm -rf /usr/lib/libbz2.a
rm -rf /usr/lib/lib{com_err,e2p,ext2fs,ss}.a
rm -rf /usr/lib/libltdl.a
rm -rf /usr/lib/libfl.a
rm -rf /usr/lib/libfl_pic.a
rm -rf /usr/lib/libz.a
