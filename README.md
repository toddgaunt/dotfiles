# Setup

## Shell
Make sure `zsh` is installed and set as your default shell with `chsh`,
then install the autosuggestion plugin:
```sh
mkdir -p ~/.zsh && git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
```

## Neovim
Neovim is the main text-editor I use. It requires a bit of manual configuration
for a new installation, but is easy to maintain after that.

### Packer
Install the package manager used to install and upgrade plugins for Neovim
```sh
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```
After installing it, start nvim and run :PackerInstall and :PackerCompile

### Nerd-fonts
Nerd-fonts include many icons and glyphs for terminal-based programs.
This will allow the terminal to display all sorts of icons using the font.
It is especially useful for Neovim and the nvim-tree plugin.
Download and install a font of your choice from https://www.nerdfonts.com
