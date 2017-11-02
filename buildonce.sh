#!/bin/sh
tar=tcc-0.9.26.tar.bz2
dir=tcc-0.9.26
prefix=$PWD/tcc.$run
rm -rf "$dir"
tar xf $tar
cd $dir
./configure --cc=${CC:-gcc} --prefix=$prefix
make -j4
make install
