#!/bin/bash

me=$(basename "$0")

log-error() {
    echo "[$me] 🔴 $*"
}

from="$HOME/Annex/Keys/"
to="/run/media/$USER/Keys/"

wait=30

while true; do
	if [[ $wait -lt 300 ]]; then
		wait=$((wait + 30))
	fi

	if [[ ! -d "$from" ]]; then
		log-error "$from does not exist or isn't mounted"
		continue
	fi

	if [[ ! -d "$to" ]]; then
		log-error "$to does not exist or isn't mounted"
		continue
	fi

	wait=0
	rsync -az --delete "$from" "$to"
	while inotifywait -r -e modify,create,delete "$from"; do
		rsync -az --delete "$from" "$to"
	done
	sleep $wait
done
