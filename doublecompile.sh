#!/bin/sh -e
# Call with no arguments to double-compile.
# Call with "3" as the first arg to double- and triple-compile.
#
# Exit 0 if no differences from stage 2 onwards.
# Exit >0 if there were differences on stage 2 or any later stage.

prefix="$PWD/tcc-root" # constant prefix for now

./buildonce.sh "$prefix" build-0

ln -sfT build-0 "$prefix"
CC="$prefix/bin/tcc" ./buildonce.sh "$prefix" build-1

ln -sfT build-1 "$prefix"
CC="$prefix/bin/tcc" ./buildonce.sh "$prefix" build-2
diffoscope --exclude-directory-metadata --html-dir build-2.diff build-1/ build-2/
echo >&2 "Double compilation reached fixed-point!"

if [ "$1" = 3 ]; then

ln -sfT build-2 "$prefix"
CC="$prefix/bin/tcc" ./buildonce.sh "$prefix" build-3
diffoscope --exclude-directory-metadata --html-dir build-3.diff build-2/ build-3/

echo >&2 "Double and triple compilation both reached fixed-point!"

fi
