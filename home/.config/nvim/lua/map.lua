-- map.lua contains all custom keybindings
local zet = require("zet")
local org = require("org")
local bib = require("bib")

-- Load which-key itself, the best neovim plugin.
local wk = require("which-key")

-- Set the leader key to space.
vim.g.mapleader = " "

-- opts is a default option set for keybindings
local default_opts = { noremap = true, silent = true }
-- map provides an easy to use way to map keybindings.
local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Unmap unused bindings to free up keys
map("n", "R", "", default_opts) -- I never use this.
map("n", "r", "", default_opts) -- I never use this.
map("n", "Y", "", default_opts) -- Yanking a line can be done with visual mode and 'y', so Y can be bound to something else
map("n", "t", "", default_opts) -- I never use this.
map("n", "T", "", default_opts) -- I never use this.
--NOTE: The leap plugin defaults to rebinding 's', so don't unbind these when that plugin is available.
--map("n", "S", "", default_opts) -- I use 'D' then enter insert mode instead of substituting a single line.
--map("n", "s", "", default_opts) -- I never use substitute for a single char

--[[Terminal mode mappings]]
--
map("t", "<Esc>", "<C-\\><C-N>", default_opts)
map("t", "<S-Space>", "<Space>", default_opts)
map("t", "<S-BS>", "<BS>", default_opts)

local function format_file()
	if vim.bo.filetype == "go" then
		GoFumport(1000)
	else
		vim.lsp.buf.format({ async = true })
	end
end

local function yank_filename()
	vim.cmd('let @" = expand("%:t")')
	print("yanked file name")
end

local function yank_filepath()
	vim.cmd('let @" = expand("%")')
	print("yanked file path")
end

local function yank_fullpath()
	vim.cmd('let @" = expand("%:p")')
	print("yanked full path")
end

-- [[Command mode mappings]] --
-- I just want to be able to use consistent key bindings to move characters when typing characters! Is that too much to ask?
vim.cmd("cnoremap <C-a> <C-b>")
vim.cmd("cnoremap <C-b> <Left>")
vim.cmd("cnoremap <C-f> <Right>")


-- [[Normal mode mappings]] --
wk.register({
	["+"] = { "<C-a>", "Increment number" },
	["-"] = { "<C-x>", "Decrement number" },
	["<C-/>"] = { '<cmd>noh<cr><cmd>let @/ = ""<cr>', "Clear search highlight" },
	["<F1>"] = { "<cmd>WhichKey<cr>", "Show keybindings" },
	["<F2>"] = { vim.lsp.buf.rename, "Rename identifer" },
	["<F3>"] = { vim.lsp.buf.references, "Open a list of references" },
	["<F4>"] = { vim.lsp.buf.definition, "Go to definition" },
	["<F5>"] = { vim.diagnostic.goto_prev, "Go to previous error" },
	["<F6>"] = { vim.diagnostic.goto_next, "Go to next error" },
	["<F7>"] = { format_file, "Format file" },
	["<C-q>"] = { "<cmd>bdelete!<cr>", "Close current buffer" },
	--["<C-l>"] = { "<cmd>Telescope find_files<cr>", "Find file" },
	-- bind both C-c and C-S-c (C-C) because linux keybindings have me swapping between both all the time :(
	["<C-c>"] = { '"+yy', "Copy selection into OS register" },
	["<C-C>"] = { '"+yy', "Copy selection into OS register" },
	["<C-v>"] = { '"+p', "Paste the OS register" },
	["<C-s>"] = { "<cmd>write<cr>", "Save buffer" },
	["<cr>"] = { "<cmd>SlimeSend<cr>", "Send current line or selection to SLIME" },
	["Y"] = { "<cmd>registers<cr>", "Show contents of registers" },
	["<C-[>"] = { "<C-[>", "Jump back in tag stack" },
	-- Allow easy movement between softwrapped lines
	["j"] = { "gj", "Down" },
	["k"] = { "gk", "Up" },
	-- Leap plugin movement
	["s"] = { "<Plug>(leap-forward-to)", "Leap forward" },
	["S"] = { "<Plug>(leap-backward-to)", "Leap backward" },
	-- Emacs movement
	["<C-a>"] = { "0", "Start of line" },
	["<C-e>"] = { "$", "End of line" },
	["<C-n>"] = { "j", "Down" },
	["<C-p>"] = { "k", "Up" },
	["<A-a>"] = { "^", "Start of line (non-blank)" },
	["<A-e>"] = { "$", "End of line" },
	["<A-n>"] = { "gj", "Down (virtual)" },
	["<A-p>"] = { "gk", "Up (virtual)" },
	-- Easy movement between windows
	["<C-h>"] = { "<C-w>h", "Move to window on left" },
	["<C-j>"] = { "<C-w>j", "Move to window below" },
	["<C-k>"] = { "<C-w>k", "Move to window above" },
	["<C-l>"] = { "<C-w>l", "Move to window on right" },
}, { mode = "n", noremap = true, silent = true })

-- [[Insert mode mappings]] --
wk.register({
	["<C-s>"] = { "<C-O>:write<cr>", "Save buffer" },
	["<C-space>"] = { "<C-x><C-o>", "Omnicomplete" },
	-- Pasting in insert mode causes indents to be inserted which isn't desirable.
	--["<C-v>"] = { "<C-R>+", "Paste the OS register" },
}, { mode = "i", noremap = true, silent = true })


-- [[Visual mode mappings]] --
-- NOTE: bindings for visual mode use ':' rather than <cmd> in order for the
-- visual mode selection to be passed to them.
wk.register({
	["v"] = { '<C-v>', "Block selection" },
	["V"] = { '<S-v>', "Line selection" },
	["s"] = { ":sort<cr>", "Sort selection (ascending)" },
	["S"] = { ":sort!<cr>", "Sort selection (descending)" },
	["<C-w>"] = { 'gw', "Format the selected lines" },
	-- bind both C-c and C-S-c (C-C) because linux keybindings have me swapping between both all the time :(
	["<C-c>"] = { '"+y', "Copy selection into OS register" },
	["<C-C>"] = { '"+y', "Copy selection into OS register" },
	["<C-x>"] = { '"+d', "Copy selection into OS register" },
	["<C-s>"] = { '<C-c>:write<cr>', "Save buffer" },
	["<cr>"] = { ":SlimeSend<cr>", "Send current line or selection to SLIME" },
}, { mode = "v", noremap = true, silent = true })

-- [[UI functions]] --
local function select_indentation()
	vim.ui.select({ "tabs", "spaces" }, {
		prompt = "Select indentation style",
	}, function(choice)
		if choice == nil then return end

		if choice == "spaces" then
			vim.o.expandtab = true
		elseif choice == "tabs" then
			vim.o.expandtab = false
		else
			vim.o.expandtab = false
		end
	end)
end

local function select_tab_length()
	vim.ui.select({ 1, 2, 3, 4, 5, 6, 7, 8 }, {
		prompt = "Select tab length",
	}, function(choice)
		if choice == nil then return end

		vim.o.tabstop = choice
	end)
end


local function toggle_spellcheck()
	if vim.g.syntax_on then
		vim.cmd("syntax off")
		vim.cmd("setlocal spell")
		vim.g.syntax_on = false
	else
		vim.cmd("setlocal nospell")
		vim.cmd("syntax on")
		vim.g.syntax_on = true
	end
end

local function new_toggle(init, fn)
   local toggle = init
   return function()
           toggle = not toggle
           fn(toggle)
   end
end


local function toggle_autocomplete(value)
   print("autocomplete=" .. tostring(value))
   require('cmp').setup.buffer { enabled = value }
end

-- bd returns a function that deletes the current buffer. If force is true, it
-- is deleted even if there is unsaved content.
local function bd(force)
	return function()
		require("mini.bufremove").delete(0, force)
	end
end

-- [[Leader key mappings for all modes]] --
local mappings = {
	['+'] = { "<cmd>Telescope oldfiles show_all_buffers=true<cr>", "Find previously opened file" },
	['='] = { "<cmd>Telescope buffers show_all_buffers=true<cr>", "Switch buffer" },
	['/'] = { "<cmd>Telescope live_grep<cr>", "Find pattern in file" },
	[':'] = { "<cmd>Telescope command_history<cr>", "Command history" },
	['<cr>'] = { "<cmd>split<cr><cmd>resize 24<cr><cmd>term<cr><cmd>set winfixheight<cr>", "Open terminal below" },
	[' '] = { "<cmd>Telescope find_files<cr>", "Find a file" },
	["<tab>"] = { "<cmd>NvimTreeFindFile<cr>", "Open the file tree" },
	["-"] = { "<cmd>Telescope workspaces<cr>", "Switch workspace" },
	a = {
		name = "Actions",
		["S"] = { "<cmd>SnippyRestart<cr>", "Refresh the snippet cache" },
		["G"] = { "<cmd>!ctags -R<cr>", "Generate tags files recursively" },
		["h"] = { '<cmd>noh<cr><cmd>let @/ = ""<cr>', "Clear search highlight" },
		["v"] = { bib.print, "Print a random Bible verse" },
		["f"] = { yank_filename, "Copy the current file's name" },
		["p"] = { yank_filepath, "Copy the current file's path" },
		['c'] = { "<cmd>checkhealth<cr>", "Check health" },
	},
	b = {
		name = "Buffers",
		['b'] = { "<cmd>Telescope buffers show_all_buffers=true<cr>", "Find a buffer" },
		["Q"] = { "<cmd>bdelete!<cr>", "Delete current buffer and window" },
		["R"] = { "<cmd>edit!<cr>", "Reload buffer from file and discard changes" },
		["["] = { "<cmd>bprev<cr>", "Previous buffer" },
		["]"] = { "<cmd>bnext<cr>", "Next buffer" },
		["d"] = { bd(false), "Delete buffer" },
		["D"] = { bd(true), "Delete buffer (force)" },
		["l"] = { "<cmd>buffers<cr>", "List buffers" },
		["n"] = { "<cmd>bnext<cr>", "Next buffer" },
		["p"] = { "<cmd>bprev<cr>", "Previous buffer" },
		["r"] = { "<cmd>edit<cr>", "Reload buffer from file" },
		["w"] = { "<cmd>write<cr>", "Write buffer to file" },
	},
	c = {
		name = "Configure",
		["g"] = { "<cmd>Gitsigns toggle_linehl<cr>", "Toggle git line highlight" },
		["i"] = { select_indentation, "Pick indentation style" },
		["l"] = { "<cmd>set cursorcolumn!<cr><cmd>set cursorline!<cr>", "Toggle cursor lines" },
		["n"] = { "<cmd>set number!<cr>", "Toggle line numbers" },
		["p"] = { "<cmd>set paste!<cr>", "Toggle paste mode" },
		["s"] = { "<cmd>ScrollbarToggle<cr>", "Toggle scrollbar" },
		["t"] = { select_tab_length, "Pick tab length" },
		["w"] = { "<cmd>set list!<cr>", "Toggle visible tabs and trailing whitespace" },
	},
	d = {
		name = "Diagnostics",
		["k"] = { vim.diagnostic.open_float, "Float diagnostic message under cursor" },
		["l"] = { "<cmd>lopen<cr>", "Open location list" },
		["n"] = { vim.diagnostic.goto_next, "Go to next error" },
		["p"] = { vim.diagnostic.goto_prev, "Go to previous error" },
		["q"] = { "<cmd>copen<cr>", "Open quickfix list" },
	},
	e = {
		name = "Edit",
		["f"] = { format_file, "Format buffer using LSP" },
		["i"] = { "gg=G", "Re-indent buffer" },
		["u"] = { ':%s/\\\\n/\\r/g<cr>', "Unescape newlines" },
		["s"] = { "<cmd>%s/\\s\\+$//e<cr>", "Strip trailing whitespace" },
	},
	f = {
		name = "Files",
		["e"] = { "<cmd>NvimTreeFindFile<cr>", "Explore the file tree from current file" },
		["E"] = { "<cmd>NvimTreeOpen<cr>", "Explore the file tree" },
		["c"] = { "<cmd>NvimTreeCollapseKeepBuffers<cr>", "Collapse file tree except on open buffers" },
		["C"] = { "<cmd>NvimTreeCollapse<cr>", "Collapse file tree" },
		["f"] = { "<cmd>Telescope find_files<cr>", "Search for a file by name" },
		["g"] = { "<cmd>Telescope git_files<cr>", "Search for a file by name tracked by Git" },
		["o"] = { "<cmd>Telescope oldfiles<cr>", "Find previously opened file" },
		["m"] = { "<cmd>Telescope live_grep<cr>", "Search for a pattern in files" },
	},
	g = {
		name = "Git",
		["C"] = { "<cmd>Git commit --amend<cr>", "Amend commit" },
		["a"] = { "<cmd>Git blame<cr>", "Show line authors (blame)" },
		["b"] = { "<cmd>Telescope git_branches<cr>", "Switch to branch" },
		["c"] = { "<cmd>Git commit<cr>", "Commit changes" },
		["d"] = { "<cmd>Gdiff<cr>", "Diff view" },
		["f"] = { "<cmd>Git fetch<cr>", "Fetch updates" },
		["g"] = { "<cmd>Telescope git_commits<cr>", "Switch to commit" },
		["l"] = { "<cmd>Git log<cr>", "View commit log" },
		["m"] = { "<cmd>Git mergetool<cr>", "Open the merge tool" },
		["p"] = { "<cmd>Git push<cr>", "Push changes" },
		["s"] = { "<cmd>Git<cr>", "Show status" },
		["u"] = { "<cmd>Git pull<cr>", "Pull changes" },
		["w"] = { "<cmd>Gwrite<cr>", "Write changes in buffer" },
	},
	h = {
		name = "Help",
		["a"] = { "<cmd>Telescope autocommands<cr>", "Search autocommands" },
		["g"] = { "<cmd>Telescope highlights<cr>", "Search highlight groups" },
		["h"] = { "<cmd>Telescope help_tags<cr>", "Search help page" },
		["k"] = { "<cmd>Telescope keymaps<cr>", "Search key maps" },
		["m"] = { "<cmd>Telescope man_pages<cr>", "Search man pages" },
		["o"] = { "<cmd>Telescope vim_options<cr>", "Search config options" },
		["w"] = { "<cmd>WhichKey<cr>", "Show which key help" },
	},
	i = {
		name = "Info",
		-- File information
		["t"] = { "<cmd>set ft?<cr>", "Show current filetype" },
		["j"] = { "<cmd>echo b:terminal_job_id<cr>", "Show terminal job ID" },
	},
	l = {
		name = "LSP",
		-- LSP information and meta-control
		["A"] = { new_toggle(true, toggle_autocomplete), "Toggle autocomplete" },
		["R"] = { "<cmd>LspRestart<cr>", "Restart the language server" },
		["S"] = { "<cmd>LspStart<cr>", "Start LSP" },
		["Q"] = { "<cmd>LspStop<cr>", "Stop LSP" },
		["l"] = { "<cmd>LspInfo<cr>", "Show language server information" },
		["f"] = { format_file, "Format buffer using LSP" },
		["c"] = { "<cmd>Telescope lsp_incoming_calls<cr>", "Incoming calls of identifier" },
		["d"] = { "<cmd>Telescope lsp_definitions<cr>", "Definitions of identifier" },
		["i"] = { "<cmd>Telescope lsp_implementations<cr>", "Implementations of identifier" },
		["k"] = { vim.lsp.buf.hover, "Show identifier information" },
		["o"] = { "<cmd>Telescope lsp_outgoing_calls<cr>", "Outgoing calls of identifier" },
		["r"] = { "<cmd>Telescope lsp_references<cr>", "References to the identifier" },
		["s"] = { "<cmd>Telescope lsp_document_symbols<cr>", "Find document identifiers" },
		["t"] = { "<cmd>Telescope lsp_type_definitions<cr>", "Find type of identifier" },
		["w"] = { "<cmd>Telescope lsp_workspace_symbols<cr>", "Find workspace identifiers" },
	},
	m = {
		name = "Mason",
		-- For Mason.nvim
		["l"] = { "<cmd>MasonLog<cr>", "View Mason logs" },
		["m"] = { "<cmd>Mason<cr>", "Manage Mason packages" },
		["u"] = { "<cmd>MasonUpdate<cr>", "Update Mason registries" },
	},
	o = {
		name = "Organize",
		["c"] = { org.cancel_task, "Cancel a task" },
		["h"] = { 'o<Esc>"=strftime("# %Y.%m.%d %a")<cr>P', "Insert a date heading" },
		["e"] = { org.create_deadline, "Create a deadline for a task" },
		["p"] = { org.mark_task_in_progress, "Mark a task as in progress" },
		["o"] = { org.mark_task_unfinished, "Mark a task as unfinished" },
		["t"] = { org.create_task, "Insert a task below" },
		["T"] = { function() org.create_task({ above = true }) end, "Insert a task above" },
		["x"] = { org.mark_task_finished, "Mark a task as finished" },
		["s"] = { 'o<Esc>"=strftime("<%Y.%m.%d %a>")<cr>P', "Insert a timestamp" },
		["v"] = { bib.insert, "Insert a random Bible verse below" },
		["V"] = { function() bib.insert({ above = true }) end, "Insert a random Bible verse above" },
	},
	p = {
		name = "Workspaces",
		["A"] = { "<cmd>WorkspacesAddDir<cr>", "Add directory of workspaces"},
		["R"] = { "<cmd>WorkspacesRemoveDir<cr>", "Remove directory of workspaces"},
		["a"] = { "<cmd>WorkspacesAdd<cr>", "Add workspace"},
		["l"] = { "<cmd>WorkspacesList<cr>", "List workspaces"},
		["n"] = { "<cmd>WorkspacesRename<cr>", "Rename workspace"},
		["p"] = { "<cmd>Telescope workspaces<cr>", "Switch workspace"},
		["r"] = { "<cmd>WorkspacesRemove<cr>", "Remove workspace"},
	},
	q = {
		name = "Sessions",
		["Q"] = { "<cmd>qa<cr>", "Quit all" },
		["d"] = { require("persistence").stop, "Disable persistence" },
		["l"] = { function() require("persistence").load({ last = true }) end, "Restore last session" },
		["o"] = { require("persistence").load, "Restore session for current directory" },
	},
	r = {
		name = "Refactor",
		["a"] = { vim.lsp.buf.code_action, "Open action list" },
		["n"] = { vim.lsp.buf.rename, "Rename identifier" },
	},
	s = {
		name = "Spellcheck",
		["a"] = { "zg", "Add word to dictionary" },
		["n"] = { "]s", "Go to next spelling error" },
		["p"] = { "[s", "Go to previous spelling error" },
		["s"] = { toggle_spellcheck, "Toggle spell check" },
		["w"] = { "zw", "Mark word as bad spelling" },
		["z"] = { "z=", "Suggest spelling correction" },
	},
	t = {
		name = "Tabs",
		["["] = { "<cmd>-tabnext<cr>", "Go to the next tab" },
		["]"] = { "<cmd>+tabnext<cr>", "Go to the previous tab" },
		["n"] = { "<cmd>+tabnext<cr>", "Go to the next tab" },
		["p"] = { "<cmd>-tabnext<cr>", "Go to the previous tab" },
		["<"] = { "<cmd>tabmove -1<cr>", "Move tab to the left" },
		[">"] = { "<cmd>tabmove +1<cr>", "Move tab to the right" },
		["O"] = { "<cmd>tabonly<cr>", "Close all other tabs" },
		["Q"] = { "<cmd>tabclose<cr>", "Close current tab" },
		["t"] = { "<cmd>tabnew<cr>", "Create a new tab" },
	},
	w = {
		name = "Windows",
		["="] = { "<C-w>=", "Equalize window size" },
		["Q"] = { "<C-w>q", "Close current split" },
		["s"] = { "<C-w>s<cmd>set wfh<cr>", "Split horizontal" },
		["t"] = { "<C-w>t", "Move window into a new tab" },
		["v"] = { "<C-w>v", "Split vertical" },
		["h"] = { "<C-w>h", "Switch to window on left" },
		["j"] = { "<C-w>j", "Switch to window below" },
		["k"] = { "<C-w>k", "Switch to window above" },
		["l"] = { "<C-w>l", "Switch to window on right" },
		["w"] = { "<C-w>w", "Cycle to next window" },
		["x"] = { "<C-w>x", "Swap with other window" },
		["a"] = { "<C-w>|", "Max out window width" },
		["z"] = { "<C-w>_", "Max out window height" },
	},
	x = {
		name = "Extensions",
		-- For Packer.nvim
		["u"] = { "<cmd>PackerUpdate<cr>", "Update plugins" },
		["i"] = { "<cmd>PackerInstall<cr>", "Install plugins" },
		["s"] = { "<cmd>PackerSnapshot backup<cr>", "Create plugin backup snapshot" },
		["r"] = { "<cmd>PackerSnapshotRollback backup<cr>", "Rollback to plugin backup snapshot" },
		["c"] = { "<cmd>PackerClean<cr>", "Clean plugins" },
		["y"] = { "<cmd>PackerCompile<cr>", "Compile plugins" },
	},
	y = {
		name = "Testing",
		["a"] = { "<cmd>TestFile<cr>", "Run all tests in file" },
		["l"] = { "<cmd>TestLast<cr>", "Run last run test" },
		["n"] = { "<cmd>TestNearest<cr>", "Run test nearest to the cursor" },
		["s"] = { "<cmd>TestSuite<cr>", "Run test suite" },
		["v"] = { "<cmd>TestVisit<cr>", "Visit last test file" },
	},
	z = {
		name = "Zettelkasten",
		["l"] = { zet.link, "Insert a link to a note" },
		["f"] = { zet.find, "Find a note" },
		["F"] = { zet.find_select, "Find a note in the selected directory" },
		["n"] = { zet.open, "Create a named note" },
		["p"] = { zet.search, "Search for a pattern" },
		["P"] = { zet.search_select, "Search in selected directory" },
		["c"] = { zet.select, "Select collection" },
		["z"] = { zet.new, "Create a new note" },
		-- Diary
		["d"] = { zet.daily, "Open daily entry" },
		["w"] = { zet.weekly, "Open weekly entry" },
		["m"] = { zet.monthly, "Open monthly entry" },
		["y"] = { zet.yearly, "Open yearly entry" },
	},
}

-- Register these mappings for both normal and visual mode.
wk.register(mappings, { mode = "n", prefix = "<leader>" })
