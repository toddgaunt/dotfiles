#!/bin/bash
# getopt.sh is an example of how to use getopt in a bash script.

usage() { echo "Usage: $0 [-s <45|90>] [-p <string>]" 1>&2; exit 1; }

while getopts ":s:p:" o; do
	case "${o}" in
		s)
			s=${OPTARG}
			((s == 45 || s == 90)) || usage
			;;
		p)
			p=${OPTARG}
			;;
		*)
			usage
			;;
	esac
done
shift $((OPTIND-1))

if [ -z "${s}" ] || [ -z "${p}" ]; then
	usage
fi

echo "s = ${s}"
echo "p = ${p}"
