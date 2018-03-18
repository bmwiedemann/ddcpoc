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

../tinycc/configure --cc="$CC" --extra-cflags="$CFLAGS" --extra-ldflags="$LDFLAGS" --prefix="$prefix"
make -j4
objcopy -D libtcc.a # because not everyone patches their binutils to have 'ar -D' as default
make install DESTDIR="$destdir"
mv "$base/$builddir/$destdir/$prefix" "$base/$destdir"

# Guess which system headers were used
c_files=$(grep -lr --exclude-dir=tests --exclude-dir=win32 --exclude-dir=examples '# *include <.*>' ../tinycc)
# not all compilers support the -M or -MM option, use GCC if it doesn't
if ${CC:-cc} -M /dev/null; then
	CCM=$CC
else
	CCM=gcc
fi
$CCM -I"$PWD" -M -MP $c_files | sed -ne 's/:$//p' | sort -u > "$base/$destdir/used_headers"
$CCM -I"$PWD" -MM -MP $c_files | sed -ne 's/:$//p' | sort -u > "$base/$destdir/used_user_headers"
comm -23 "$base/$destdir/used_headers" "$base/$destdir/used_user_headers" > "$base/$destdir/used_system_headers"
