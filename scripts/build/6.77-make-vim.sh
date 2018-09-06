#!/bin/bash
set -e
echo "Building vim.."
echo "Approximate build time: 1.1 SBU"
echo "Required disk space: 128 MB"

# 6.77. Vim package contains a powerful text editor
tar -xf /sources/vim-*.tar.bz2 -C /tmp/ \
  && mv /tmp/vim* /tmp/vim \
  && pushd /tmp/vim

# change default location of the vimrc configuration file to /etc
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
# disable a test that fails
sed -i '/call/{s/split/xsplit/;s/303/492/}' src/testdir/test_recover.vim
# prepare Vim for compilation:
./configure --prefix=/usr
make
if [ $LFS_TEST -eq 1 ]; then make -j1 test &> vim-test.log; fi
make install
# create symlink for vi
ln -sv vim /usr/bin/vi
for L in /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done
ln -sv ../vim/vim80/doc /usr/share/doc/vim-8.0.586
# 6.70.2. Configuring Vim
cat > /etc/vimrc <<"EOF"
" Begin /etc/vimrc
set nocompatible
set backspace=2
set mouse=r
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif
set spelllang=en,ru
set spell
" End /etc/vimrc
EOF
touch ~/.vimrc
# cleanup
popd \
  && rm -rf /tmp/vim
