#!/usr/bin/env bash
#
# Convert all files of extension $1 to extension $2

PREFIX=$(basename $0)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
	echo "usage: $PREFIX [-h|--help] [-D|--dry-run] <from> <to>"
}

TEMP=$(getopt -o 'd:h' --long 'dry-run,help' -n "$me" -- "$@")
if [[ $? -ne 0 ]]; then
	usage
	exit 1
fi

# Note the quotes around "$TEMP": they are essential!
eval set -- "$TEMP"
unset TEMP

DRY_RUN=0

while true; do
	case "$1" in
		'-h'|'--help')
			usage
			exit 0
		;;
		'-D'|'--dry-run')
			DRY_RUN=1
			shift 1
			continue
		;;
		'--')
			shift
			break
		;;
		*)
			log-fatal 'getopt error!' >&2
			exit 1
		;;
	esac
done

if [[ "$1" == "" || "$2" == "" ]]; then
	usage
	exit 1
fi

FROM_DIR="$1"
TO_DIR="$2"
QUALITY=3 # A qualtiy of 3 targets ~112kbps, a good default.
#QUALITY=5 # Alternatively use 5 for ~160kbps

shopt -s globstar
for i in "$FROM_DIR"/**/*.flac; do
	subpath=${i#$FROM_DIR}
	from="$i"
	to="$TO_DIR${subpath%.flac}.ogg"
	to_dir=$(dirname "$to")
	if [[ $DRY_RUN -eq 1 ]]; then
		printf -- "mkdir -p '$to_dir'\n"
		printf -- "ffmpeg '${CYAN}$from${NC}' -> '${CYAN}$to${NC}'\n"
	else
		mkdir -p "$to_dir"
		if ! [ -f "$OGG" ]; then
			< /dev/null ffmpeg \
				-y \
				-i "$from" \
				-vn \
				-acodec libvorbis \
				-q "$QUALITY" \
				"$to"
		fi
	fi
done
