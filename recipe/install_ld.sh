#/bin/bash

# set up ld specific symbolic links

echo "install ld ..."

set -ex

cd build

CHOST="${ctng_triplet}"
OLD_CHOST="${ctng_triplet_old}"
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/$OLD_CHOST/bin
mkdir -p $PREFIX/$CHOST/bin
if [[ $target_platform == osx-* ]]; then
  echo "no ld support ..."
else
  cp $PWD/prefix_strip/bin/$CHOST-ld $PREFIX/bin/$CHOST-ld
  if [[ "${CHOST}" != "${OLD_CHOST}" ]]; then
    ln -s $PREFIX/bin/$CHOST-ld $PREFIX/bin/$OLD_CHOST-ld
    ln -s $PREFIX/bin/$CHOST-ld $PREFIX/$OLD_CHOST/bin/ld
  fi
  ln -s $PREFIX/bin/$CHOST-ld $PREFIX/$CHOST/bin/ld
fi

echo "ld installed"

