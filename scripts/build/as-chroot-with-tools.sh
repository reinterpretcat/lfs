#!/bin/bash
set -e
echo "Continue with chroot environment.."
. /tools/.variables

# SKIP remove the "I have no name!" promp
# exec /tools/bin/bash --login +h

# build toolchain
sh /tools/6.5-create-directories.sh
sh /tools/6.6-create-essentials.sh
sh /tools/6.7-make-linux-api-headers.sh
sh /tools/6.8-make-man-pages.sh
sh /tools/6.9-make-glibc.sh
sh /tools/6.10-adjust-toolchain.sh
sh /tools/6.11-make-zlib.sh
sh /tools/6.12-make-file.sh
sh /tools/6.13-make-readline.sh
sh /tools/6.14-make-m4.sh
sh /tools/6.15-make-bc.sh
sh /tools/6.16-make-binutils.sh
sh /tools/6.17-make-gmp.sh
sh /tools/6.18-make-mpfr.sh
sh /tools/6.19-make-mpc.sh
sh /tools/6.20-make-gcc.sh
sh /tools/6.21-make-bzip2.sh
sh /tools/6.22-make-pkg-config.sh
sh /tools/6.23-make-ncurses.sh
sh /tools/6.24-make-attr.sh
sh /tools/6.25-make-acl.sh
sh /tools/6.26-make-libcap.sh
sh /tools/6.27-make-sed.sh
sh /tools/6.28-make-shadow.sh
sh /tools/6.29-make-psmisc.sh
sh /tools/6.30-make-iana-etc.sh
sh /tools/6.31-make-bison.sh
sh /tools/6.32-make-flex.sh
sh /tools/6.33-make-grep.sh
sh /tools/6.34-make-bash.sh

# SKIP switching to built bash
#exec /bin/bash --login +h

sh /tools/6.35-make-libtool.sh
sh /tools/6.36-make-gdbm.sh
sh /tools/6.37-make-gperf.sh
sh /tools/6.38-make-expat.sh
sh /tools/6.39-make-inetutils.sh
sh /tools/6.40-make-perl.sh
sh /tools/6.41-make-xml-parser.sh
sh /tools/6.42-make-intltool.sh
sh /tools/6.43-make-autoconf.sh
sh /tools/6.44-make-automake.sh
sh /tools/6.45-make-xz.sh
sh /tools/6.46-make-kmod.sh
sh /tools/6.47-make-gettext.sh
sh /tools/6.48-make-procps-ng.sh
sh /tools/6.49-make-e2fsprogs.sh
sh /tools/6.50-make-coreutils.sh
sh /tools/6.51-make-diffutils.sh
sh /tools/6.52-make-gawk.sh
sh /tools/6.53-make-findutils.sh
sh /tools/6.54-make-groff.sh
sh /tools/6.55-make-grub.sh
sh /tools/6.56-make-less.sh
sh /tools/6.57-make-gzip.sh
sh /tools/6.58-make-iproute2.sh
sh /tools/6.59-make-kbd.sh
sh /tools/6.60-make-libpipeline.sh
sh /tools/6.61-make-make.sh
sh /tools/6.62-make-patch.sh
sh /tools/6.63-make-sysklogd.sh
sh /tools/6.64-make-sysvinit.sh
sh /tools/6.65-make-eudev.sh
sh /tools/6.66-make-util-linux.sh
sh /tools/6.67-make-man-db.sh
sh /tools/6.68-make-tar.sh
sh /tools/6.69-make-texinfo.sh
sh /tools/6.70-make-vim.sh
sh /tools/6.71-strip.sh
sh /tools/6.72-clean.sh

exit
