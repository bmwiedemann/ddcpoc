#!/bin/sh
dir=tcc-build
prefix=$PWD/tcc.$run
test -e tinycc || git clone git://repo.or.cz/tinycc.git
rm -rf "$dir"
cp -a tinycc $dir
cd $dir
./configure --cc=${CC:-gcc} --prefix=$prefix
make -j4
make install
