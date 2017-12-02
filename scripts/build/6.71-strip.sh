#!/bin/bash
set -e
echo "Stripping again.."

# place the debugging symbols for selected libraries in separate files.
# This debugging information is needed if running regression tests that
# use valgrind or gdb later in BLFS
save_lib="ld-2.26.so libc-2.26.so libpthread-2.26.so libthread_db-1.0.so"

cd /lib

for LIB in $save_lib; do
    objcopy --only-keep-debug $LIB $LIB.dbg
    strip --strip-unneeded $LIB
    objcopy --add-gnu-debuglink=$LIB.dbg $LIB
done

save_usrlib="libquadmath.so.0.0.0 libstdc++.so.6.0.24
             libmpx.so.2.0.1 libmpxwrappers.so.2.0.1 libitm.so.1.0.0
             libcilkrts.so.5.0.0 libatomic.so.1.2.0"

cd /usr/lib

for LIB in $save_usrlib; do
    objcopy --only-keep-debug $LIB $LIB.dbg
    strip --strip-unneeded $LIB
    objcopy --add-gnu-debuglink=$LIB.dbg $LIB
done

unset LIB save_lib save_usrlib

# strip
/tools/bin/find /usr/lib -type f -name \*.a \
  -exec /tools/bin/strip --strip-debug {} ';'

/tools/bin/find /lib /usr/lib -type f \( -name \*.so* -a ! -name \*dbg \) \
  -exec /tools/bin/strip --strip-unneeded {} ';'

/tools/bin/find /{bin,sbin} /usr/{bin,sbin,libexec} -type f \
  -exec /tools/bin/strip --strip-all {} ';'
