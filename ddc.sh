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

{
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
		echo >&2 "Try running \`CC=$cc ./doublecompile.sh -3\` to check for bugs."
		echo >&2 "If it reaches a fixed-point, then it's more likely that it is *not* buggy and"
		echo >&2 "is intentionally backdoored. (OTOH, if it does not reach a fixed-point, it "
		echo >&2 "may be buggy/nondeterministic *and* backdoored.)"
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
