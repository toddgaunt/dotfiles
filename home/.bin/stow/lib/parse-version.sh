function parse-version() {
	local version
	version="$(echo "$1" | grep -oe '[[:digit:]]\.[[:digit:]]\+\(\.[[:digit:]]\+\)\?')"

	local major_number="${version%%\.*}"
	local minor_number_step="${version#*.}"
	local minor_number="${minor_number_step%.*}"
	local patch_number="${version##*.}"

	echo "$major_number $minor_number $patch_number"
}
