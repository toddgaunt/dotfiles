# interact.sh
# Interact provides common bash script functions for scripts that
# need user input or are otherwise interactive. It also provides
# logging

source color.sh

me="$(basename "$0")"

log() {
    echo "$me [${BLU}info${CLR}] $*"
}

log-warn() {
    echo "$me [${YLW}warn${CLR}] $*"
}

log-fatal() {
    echo "$me [${RED}fatal${CLR}] $*"
    exit 1
}

# require takes a list of commands as input, and if any cannot be found in the path and error message will be printed.
require() {
    local missing=0
    local commands=""
    for cmd in "$@"; do
        command -v "$cmd" >/dev/null 2>&1 || { commands="$commands $cmd"; missing=1; }
    done

    # Even if only one pre-requisite is missing, exit since none are optional
    if [ $missing -ne 0 ]; then
        log-fatal "required:$commands"
        #if yes_or_no "Would you like to install them now?"; then
            #INSTALLCMD=sudo dnf install
            #$INSTALLCMD $commands
            #return 0
        #else
            #exit 1
        #fi
    fi
}

# yes_or_no provides a standard yes or no prompt using the first argument as the prompt.
yes_or_no() {
    prompt=$1
    while true; do
        read -rp "$prompt [Y/n]" yn
        if [[ "$yn" == "" ]]; then
            yn="Y"
        fi
        case "$yn" in
            [Yy]* )
                return 0;;
            [Nn]* )
                return 1;;
            * )
                echo "Enter y for yes or n for no";;
        esac
    done
}

# no_args is used like so: `no_args "description" $@`.
no_args() {
    local description="$1"
    local arg="$2"

    if [[ "$arg" != "" ]] && [[ "$arg" != "--" ]]; then
        echo "$me [-h]"
        echo ""
        echo "$description"
        if [[ "$arg" == "-h" ]] || [[ "$arg" == "--help" ]]; then
            exit 0
        else
            exit 1
        fi
    fi
}
