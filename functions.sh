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
