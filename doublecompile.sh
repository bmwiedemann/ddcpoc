#!/bin/sh -e

. "$(dirname "$(readlink -f "$0")")/functions.sh"

triple=false
while getopts '3h?' o; do
	case $o in
	3 )	triple=true;;
	h|\? ) cat >&2 <<eof
Usage: $0 [-3] [<build-prefix>]

Double- or triple-compile in <build-prefix>-{1,2,3...}.

If triple-compiling, we check that the 2nd and 3rd build reaches a fixed-point,
and exit non-zero if this is not the case (even if the build succeeded).
eof
		exit 2;;
	esac
done
shift $(expr $OPTIND - 1)

prefix="$PWD/tcc-root" # constant prefix for now
buildprefix="${1:-build}"

if [ -z "$CC" ]; then
	echo >&2 "setting CC=gcc"
	export CC=gcc
fi

./buildonce.sh "$prefix" "$buildprefix-1"

unset CC CFLAGS LDFLAGS

ln -sfT "$buildprefix-1" "$prefix"
CC="$prefix/bin/tcc" ./buildonce.sh "$prefix" "$buildprefix-2"
sums "$buildprefix-2"

if $triple; then

ln -sfT "$buildprefix-2" "$prefix"
CC="$prefix/bin/tcc" ./buildonce.sh "$prefix" "$buildprefix-3"
checkdiff "$buildprefix-2" "$buildprefix-3" "Triple compilation reached fixed-point!"

fi
