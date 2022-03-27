#/bin/bash

echo "build binutils ..."

if [[ $target_platform == osx-* ]]; then
  export CPPFLAGS="$CPPFLAGS -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
  export CFLAGS="$CFLAGS -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
  export CXXFLAGS="$CXXFLAGS -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
  export LDFLAGS="$LDFLAGS -Wl,-pie -Wl,-headerpad_max_install_names -Wl,-dead_strip_dylibs"
  export CC=clang
  export CXX=clang++
fi
export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"

DEFSYSROOT=""
if [[ $target_platform == linux-* ]]; then
  DEFSYSROOT="--with-sysroot=$PREFIX/$HOST/sysroot"
fi
## on linux --with-sysroot=$PREFIX/$HOST/sysroot

mkdir -p build
cd build
../binutils/configure --prefix="${PREFIX}" \
  --enable-interwork --enable-ld=yes --enable-gold=yes --enable-plugins --disable-multilib \
  --disable-sim --disable-gdb --disable-nls --disable-werror --enable-default-pie \
  --enable-deterministic-archives --enable-64-bit-bfd \
  --target=$HOST ${DEFSYSROOT}

make

# required to run and do until now unstaged builds
make check || true

make install-strip

mkdir prefix_strip
mv $PREFIX/* prefix_strip/.

export CHOST="${ctng_triplet}"

# test that we are installing without prefix
if [[ ! -f ${PREFIX}/bin/${CHOST}-addr2line ]]; then
  for tool in addr2line ar c++filt elfedit ld as dwp gprof ld.bfd ld.gold gold nm objcopy objdump ranlib readelf size strings strip; do
     echo "move ${tool} to ${CHOST}-${tool} ..."
     # not all architectures provide all binaries ...
     mv prefix_strip/bin/$tool prefix_strip/bin/$CHOST-$tool  || true
  done
fi

echo "initial build done"
