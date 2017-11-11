#!/bin/sh -e

. "$(dirname "$(readlink -f "$0")")/functions.sh"

build3=false
build4=false
while getopts '34h?' o; do
	case $o in
	3 )	build3=true;;
	4 )	build4=true;;
	h|\? ) cat >&2 <<eof
Usage: $0 [-3|-4] [<build-prefix>]

Double-compile (or more) in <build-prefix>-{1,2,3...}.

If 3x-compiling, we check that the 2nd and 3rd build reaches a fixed-point,
and exit non-zero if this is not the case (even if the build succeeded).

If 4x-compiling, we check that the 3rd and 4th build reaches a fixed-point,
and exit non-zero if this is not the case (even if the build succeeded).
eof
		exit 2;;
	esac
done
shift $(expr $OPTIND - 1)

prefix="$PWD/tcc-root" # constant prefix for now
buildprefix="${1:-build}"

if [ -z "$CC" ]; then
	echo >&2 "setting CC=cc"
	export CC=cc
fi

./buildonce.sh "$prefix" "$buildprefix-1"

unset CC CFLAGS LDFLAGS

ln -sfT "$buildprefix-1" "$prefix"
CC="$prefix/bin/tcc" ./buildonce.sh "$prefix" "$buildprefix-2"
sums "$buildprefix-2"

if $build3 || $build4; then
ln -sfT "$buildprefix-2" "$prefix"
CC="$prefix/bin/tcc" ./buildonce.sh "$prefix" "$buildprefix-3"
$build4 || checkdiff "$buildprefix-2" "$buildprefix-3" "Triple compilation reached fixed-point!"
fi

if $build4; then
ln -sfT "$buildprefix-3" "$prefix"
CC="$prefix/bin/tcc" ./buildonce.sh "$prefix" "$buildprefix-4"
checkdiff "$buildprefix-3" "$buildprefix-4" "4x compilation reached fixed-point!"
fi
