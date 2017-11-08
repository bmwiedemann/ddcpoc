sums() {(
	cd "$1"
	find . -type f -printf '%P\0' | sort -z | xargs -r0 sha256sum | \
	  { tee /dev/fd/3 | sha256sum; } 3>&1
)}

checkdiff() {
	if diff -ru "$1" "$2"; then
		sums "$2"
		shift 2
		echo >&2 "$@"
	else
		diffoscope --exclude-directory-metadata --html-dir "$2.diff" "$1" "$2"
	fi
}
