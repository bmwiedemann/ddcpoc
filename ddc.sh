#!/bin/sh -e
# DDC tinycc with gcc and whatever else we can detect
#

. "$(dirname "$(readlink -f "$0")")/functions.sh"

dc() {
	set -x
	eval $(cenv $1) ./doublecompile.sh build-"$1"
	{ set +x; } 2>/dev/null
}

cenv() {
	if [ -f "$1.cflags" ]; then
		echo CC=\"$1\" CFLAGS=\"$(cat $1.cflags)\"
	else
		echo CC=\"$1\"
	fi
}

compiler0="cc"

if [ -z "$compilers" ]; then
	compilers="gcc"
	which clang >/dev/null 2>&1 && compilers="$compilers clang"
	which icc >/dev/null 2>&1 && compilers="$compilers icc"
	which pgcc >/dev/null 2>&1 && compilers="$compilers pgcc"
fi

echo >&2 "DDC verifying these compilers: $compiler0 $compilers"

for cc in $compiler0 $compilers; do
	dc $cc
done

{
echo "-- Source code:"
GIT_DIR=tinycc/.git git rev-parse @
echo "-- Build path:"
echo "$PWD"
echo "-- Linked libraries:"
for cc in $compiler0 $compilers; do ldd -r build-$cc-2/bin/tcc | sed -nre 's/.* => (.*) \(.*\)/\1/gp'; done | \
	sort -u | xargs -rn1 sha256sum
echo "-- System headers:"
for cc in $compiler0 $compilers; do cat build-$cc-2/used_system_headers; rm -f build-$cc-2/used_*headers; done | \
	sort -u | xargs -rn1 sha256sum
} > dependencies.txt

echo >&2 "DDC finished, comparing..."

x=0
for cc in $compilers; do
	if checkdiff "build-cc-2" "build-$cc-2" "DDC verified $cc against cc."; then
		:
	else
		x=$?
		echo >&2 "DDC failed for $cc..."
		echo >&2 "Try running \`$(cenv $cc) ./doublecompile.sh -3\` to check for bugs."
		echo >&2 "If it reaches a fixed-point, then it's more likely that it is *not* buggy and"
		echo >&2 "is intentionally backdoored. OTOH, if it does not reach a fixed-point, it "
		echo >&2 "may be buggy/nondeterministic *and* backdoored. If it reaches a fixed-point"
		echo >&2 "with -4 but not with -3 then it's just buggy."
	fi
done
test $x = 0 || exit $x

sums build-cc-2

echo >&2 "DDC complete; verified all of: $compiler0 $compilers."
echo >&2 "Either these are all not backdoored, or they are all backdoored in exactly the same way."

cat >&2 <<eof
Your artifact hashes may dependent on some system-specific things, see
dependencies.txt for details. For best results, re-run this on a different
system where the dependencies are different, and try to get the same hashes.
eof
