#!/bin/bash
set -e
echo "Building Ninja.."
echo "Approximate build time: 0.2 SBU"
echo "Required disk space: 40 MB"

# 6.51. Ninja is a small build system with a focus on speed.
tar -xf /sources/ninja-*.tar.gz -C /tmp/ \
  && mv /tmp/ninja-* /tmp/ninja \
  && pushd /tmp/ninja

# Using the optional patch below allows a user to limit the number of parallel processes
# via an environment variable, NINJAJOBS. For example setting:
export NINJAJOBS=$JOB_COUNT

# prepare for compilation
patch -Np1 -i /sources/ninja-1.8.2-add_NINJAJOBS_var-1.patch

# Build package
python3 configure.py --bootstrap

# Run tests
if [ $LFS_TEST -eq 1 ]; then
    python3 configure.py
    ./ninja ninja_test
    ./ninja_test --gtest_filter=-SubprocessTest.SetWithLots || true
fi

# Install package
install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

# cleanup
popd \
  && rm -rf /tmp/python
