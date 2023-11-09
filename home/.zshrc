# Use emacs keybindings to avoid confusion when emulating a terminal when
# inside an editor with vim keybindings
set -o emacs

# Disable software flow control (ctrl-z ctrl-q)
stty -ixon

# Enable zsh autocompletion
autoload -Uz compinit -u && compinit -u

# Enable editing of the current command with $EDITOR
autoload -z edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
bindkey '^ ' autosuggest-accept

# Rebind C-w to delete backwards until '/' rather than ' '. To do this, we must
# create a function and bind it as a widget for zsh to use.
function backward-delete-until-slash() {
	local WORDCHARS=${WORDCHARS:s#/#}
	zle backward-kill-word
}
zle -N backward-delete-until-slash
bindkey '^W' backward-delete-until-slash

# Search through history
function hist() {
	if command -v fzf &> /dev/null; then
		fc -Dlim "*$@*" 1 | fzf
	else
		fc -Dlim "*$@*" 1
	fi
}

# Allow shared history between shells
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY

# parse-git-branch parses the current git branch from the current working directory
# if within a git repository. The return value is a string that can be interpreted
# by zsh within a prompt to display the current git branch in color.
function parse-git-branch() {
	max_len=64
	branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
	if [[ ${#branch} -gt $max_len ]]; then
		branch="${branch:0:$max_len}…"
	fi
	if [[ "$branch" != "" ]]; then
		echo "%F{magenta}:%f%F{green}${branch}%f"
	fi
}

# check-last-exit-code displays the last command's exit code on the prompt
function check-last-exit-code() {
	local last_exit_code=$?
	local exit_code_prompt=''
	if [[ $last_exit_code -eq 0 ]]; then
		exit_code_prompt="%F{green}ok%f"
	else
		exit_code_prompt="%F{red}$last_exit_code%f"
	fi
	echo "$exit_code_prompt"
}

setopt PROMPT_SUBST

# Left-hand prompt
NEWLINE=$'\n'
PROMPT='%F{magenta}%n@%m[%f%F{blue}%~%f$(parse-git-branch)%F{magenta}]%f${NEWLINE}%(1j.(%j).)> '
RPROMPT='%F{magenta}[%f$(check-last-exit-code)%F{magenta}]%f'

# gpg configuration
gpg-agent > /dev/null 2>&1 || gpg-agent --daemon
export GPG_TTY=$(tty)

# Aliases
alias bindings="print -rl -- ${(k)aliases}"
alias python='python3'
alias cx='chmod +x'
alias e='edit'
alias g='git'
alias grep='rg'
alias j='jobs'
alias b='bg'
alias sxiv='sxiv -a'
alias genrsa='openssl genrsa'
# The exa command is good replacement for ls and tree
if [[ -x "$(command -v exa)" ]]; then
	alias ls='exa -g'
	alias tree='exa --tree'
fi
alias archive-url="archive-url --directory=$HOME/Annex/Sites"
alias sane="stty sane"
alias sudoenv="sudo -E"

# Zsh Plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# Finally, source any additional machine-specific configuration>
if [[ -f "$HOME/.rc" ]]; then
	source "$HOME/.rc"
fi
