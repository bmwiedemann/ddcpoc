#!/bin/sh -e
# DDC tinycc with gcc and clang-4.0
#

. "$(dirname "$(readlink -f "$0")")/functions.sh"

dc() {
	CC="$1" ./doublecompile.sh build-"$1"
}

compiler0="cc"
compilers="gcc clang-4.0"

for cc in $compiler0 $compilers; do
	dc $cc
done

echo >&2 "DDC finished, comparing..."

for cc in $compilers; do
	checkdiff "build-cc-2" "build-$cc-2" \
	"DDC verified $cc against cc."
done

echo >&2 "DDC complete; verified all of: $compiler0 $compilers."
