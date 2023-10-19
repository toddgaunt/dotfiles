-- opt.lua contains all built-in neovim option configuration

-- Record the git branch name in a buffer local variable
vim.cmd('let b:git_status = "unknown"')

-- Create an autocmd to get the git branch name to display in the status line.
vim.cmd( 'autocmd BufEnter,FocusGained,BufWritePost * let b:git_status = substitute(system("git rev-parse --abbrev-ref HEAD 2> /dev/null"), "\\n", " ", "g")')
-- User interface
vim.cmd("colorscheme minimal")
--vim.cmd("let &statusline = '%<[%P] %f %h%m%r%=master%=%([%l,%c%V]%)'") -- Set the status line to the way I like it, without git branch info
vim.cmd("let &statusline = '%<[%P] %f %h%m%r%=%{get(b:,\"git_status\",\"\")}%=%([%l,%c%V]%)'") -- Set the status line to the way I like it, with git branch info
-- Keep the gutter always open
-- vim.opt.signcolumn = "yes"
-- Enable the mouse in all modes
vim.opt.mouse = "a"
vim.opt.guicursor = "n:block-blinkwait500-blinkoff500-blinkon500,v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
vim.opt.cmdheight = 2
vim.opt.lazyredraw = true
vim.opt.number = true
vim.opt.ruler = true
vim.opt.scrolloff = 0
vim.opt.syntax = "on"
vim.opt.timeoutlen = 0 -- Instantly show which-key when pressing a keybinding
vim.opt.wrap = true
vim.opt.listchars = "tab:>·,trail:+"
vim.opt.list = true
vim.opt.showtabline = 1
vim.opt.foldenable = false

-- Built-in Completion Settings
vim.cmd("set omnifunc=syntaxcomplete#Complete")
vim.opt.completeopt = "menu,menuone,noselect"

-- Terminal Settings
vim.cmd("autocmd TermOpen * setlocal nonu") -- Disable line numbers in terminals

-- Window splitting
vim.cmd("set noequalalways") -- Don't automatically change my split sizes when opening or closing splits!
vim.opt.splitbelow = true    -- Move cursor below when splitting
vim.opt.splitright = true    -- Move cursor to the right when splitting

-- Search
vim.opt.hlsearch = true
vim.opt.inccommand = "nosplit"
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Persistent files and undo/redo
vim.opt.autoread = true
vim.opt.autowrite = true
vim.opt.autowriteall = true
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.local/share/nvim/undo"
vim.opt.swapfile = false

-- File Formatting
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0   -- Defaults to tabstop
vim.opt.softtabstop = -1 -- Defaults to shiftwidth
vim.opt.expandtab = false

-- Ctags
vim.opt.tags = "./tags;,tags;" -- Recursively read ctags tags files
