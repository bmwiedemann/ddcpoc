#!/bin/sh -e
# Call with no arguments to double-compile.
# Call with "3" as the first arg to double- and triple-compile.
#
# Exit 0 if no differences from stage 2 onwards.
# Exit >0 if there were differences on stage 2 or any later stage.

prefix="$PWD/tcc-root" # constant prefix for now

sums() {
	find "$1" -type f -exec sha256sum '{}' \;
}

checkdiff() {
	if diff -ru "$1" "$2"; then
		sums "$2"
		shift 2
		echo >&2 "$@"
	else
		diffoscope --exclude-directory-metadata --html-dir "$2.diff" "$1" "$2"
	fi
}

if [ -z "$CC" ]; then
	echo >&2 "setting CC=gcc"
	export CC=gcc
fi

./buildonce.sh "$prefix" build-0

unset CC CFLAGS LDFLAGS

ln -sfT build-0 "$prefix"
CC="$prefix/bin/tcc" ./buildonce.sh "$prefix" build-1
sums build-1/

ln -sfT build-1 "$prefix"
CC="$prefix/bin/tcc" ./buildonce.sh "$prefix" build-2
checkdiff build-1/ build-2/ "Double compilation reached fixed-point!"

if [ "$1" = 3 ]; then

ln -sfT build-2 "$prefix"
CC="$prefix/bin/tcc" ./buildonce.sh "$prefix" build-3
checkdiff build-2/ build-3/ "Double and triple compilation both reached fixed-point!"

fi
