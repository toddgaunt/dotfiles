#[XDG User Directories]#
XDG_CONFIG_HOME="$HOME/.config"
XDG_CACHE_HOME="$HOME/.cache"
XDG_DATA_HOME="$HOME/.local/share"
XDG_STATE_HOME="$HOME/.local/state"

#[Default Programs]#
export VISUAL="nvim"
export EDITOR="nvim"
#export LESS="-irX"
export PAGER="less"

#[History]#
mkdir -p "$XDG_DATA_HOME/zsh/"
export HISTFILE="$XDG_DATA_HOME/zsh/history"
export HISTTIMEFORMAT="[%F %T]"
export HISTSIZE=10000000
export SAVEHIST=$HISTSIZE

#[Golang]#
export GOPATH="$XDG_DATA_HOME/go"
export PATH="$GOPATH/bin:$PATH"

#[Local Bin]#
export PATH="$HOME/.local/bin:$PATH"

#[User Scripts]#
export PATH="$HOME/.bin:$PATH"

#[Project Namespaces]#
export GH="$HOME/Annex/Code/github.com"
export BB="$HOME/Annex/Code/bastionburrow.com"

if [[ -f "$HOME/.env" ]]; then
	source "$HOME/.env"
fi
