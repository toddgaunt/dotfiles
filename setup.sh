#!/usr/bin/env bash

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
    fi
}

require git stow

echo "zsh-autosuggestions: plugin to automatically suggest completions based on command history"
mkdir -p ~/.zsh && git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
echo ""
echo "=> install zsh and set it as your default shell with chsh"
echo ""

echo "packer: install and update packages automatically for nvim"
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
echo ""
echo "=> start nvim and run :PackerInstall and :PackerCompile"
echo ""
