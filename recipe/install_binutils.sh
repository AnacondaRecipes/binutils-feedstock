#/bin/bash

# contains HOST binaries, and OLD_HOST binaries as links to HOST one
# HOST/bin/tools point to /bin/HOST-tools
# OLD_HOST/bin/tools point to /bin/HOST-tools
set -x

echo "install binutils ..."

# make sure build dependencies are specific to archs
LDDEPS="as dwp gprof ld.bfd ld.gold"
if [[ "$target_platform" == osx-* ]]; then
  LDDEPS=""
fi

export HOST="${ctng_triplet}"
export OLD_HOST="${ctng_triplet_old}"

mkdir -p $PREFIX/$OLD_HOST/bin

cd build

cp -r prefix_strip/* $PREFIX/.

# Remove hardlinks and replace them by softlinks
for tool in addr2line ar c++filt elfedit ${LDDEPS} nm objcopy objdump ranlib readelf size strings strip; do
  rm -rf $PREFIX/$HOST/bin/$tool || true
  ln -s $PREFIX/bin/$HOST-$tool $PREFIX/$HOST/bin/$tool || true;
  if [[ "${OLD_HOST}" != "${HOST}" ]]; then
    ln -s $PREFIX/bin/$HOST-$tool $PREFIX/$OLD_HOST/bin/$tool || true;
    ln -s $PREFIX/bin/$HOST-$tool $PREFIX/bin/$OLD_HOST-$tool || true;
  fi
done

echo "binutils installed"
