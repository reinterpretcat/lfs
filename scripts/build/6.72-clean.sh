#!/bin/bash
set -e
echo "Cleaning up.."

# cleanup temp files
rm -rf /tmp/*

# cleanup leftovers
rm -rf /usr/lib/lib{bfd,opcodes}.a
rm -rf /usr/lib/libbz2.a
rm -rf /usr/lib/lib{com_err,e2p,ext2fs,ss}.a
rm -rf /usr/lib/libltdl.a
rm -rf /usr/lib/libfl.a
rm -rf /usr/lib/libfl_pic.a
rm -rf /usr/lib/libz.a
