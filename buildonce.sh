#!/bin/sh -e

builddir=tcc-build # constant build path for now

prefix="$1"
destdir="$2"
test -n "$destdir"
test -e tinycc || git clone git://repo.or.cz/tinycc.git

rm -rf "$builddir" && mkdir -p "$builddir"
rm -rf "$destdir" # directory will be created later by the last "mv"

base="$PWD"
cd "$builddir"

../tinycc/configure --cc="${CC:-gcc}" --prefix="$prefix"
make -j4
make install DESTDIR="$destdir"
mv "$base/$builddir/$destdir/$prefix" "$base/$destdir"
