-- map.lua contains all custom keybindings

-- Load local modules
local zet = require("zet")
local org = require("org")
local bib = require("bib")

-- Load which-key, the best neovim plugin.
local wk = require('which-key')

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

-- The function to set the ignore patterns can be bound
-- to allow this to be changed by user input. A default
-- table of ignore patterns may be passed in as the argument.
local function set_file_ignore_patterns(file_ignore_patterns)
	require("telescope").setup({
		defaults = {
			file_ignore_patterns = file_ignore_patterns,
		},
	})

	return function()
		vim.ui.input({
			prompt = "Set pattern to use for ignore files when searching: ",
			default = table.concat(file_ignore_patterns, ",")
		}, function(input)
			if input == nil then return end

			if input ~= "" then
				file_ignore_patterns = vim.split(input, ",")
				print("Ignore patterns set to: " .. table.concat(file_ignore_patterns, ","))
			else
				file_ignore_patterns = {}
				print("Ignore patterns cleared")
			end
			require("telescope").setup({
				defaults = {
					file_ignore_patterns = file_ignore_patterns,
				},
			})
		end)
	end
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

--local function yank_fullpath()
--vim.cmd('let @" = expand("%:p")')
--print("yanked full path")
--end

-- [[Command mode mappings]] --
-- I just want to be able to use consistent key bindings to move characters when typing characters! Is that too much to ask?
vim.cmd("cnoremap <C-a> <C-b>")
vim.cmd("cnoremap <C-b> <Left>")
vim.cmd("cnoremap <C-f> <Right>")

local function get_loc()
	local path = vim.api.nvim_buf_get_name(0)
	local loc = vim.api.nvim_win_get_cursor(0)

	-- Note: this only works as expected when the file you are copying is inside the cwd.
	--local relpath = path.sub(path, #cwd + 1) .. ":" ..  tostring(loc[1])

	-- Instead this is used since only fullpath yanking behaves as expected.
	local pathloc = path .. ":" .. tostring(loc[1])

	vim.fn.setreg("", pathloc)
	vim.fn.setreg("+", pathloc)
end

local function getVisualSelection()
	vim.cmd('noau normal! "vy"')
	local text = vim.fn.getreg('v')
	vim.fn.setreg('v', {})

	text = string.gsub(text, "\n", "")
	if #text > 0 then
		return text
	else
		return ''
	end
end

-- [[Normal mode mappings]] --
wk.register({
	['y@'] = { get_loc, "File path" },
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
	["<C-c>"] = { '"+yy', "Copy selection into OS register" },
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
	-- Note: Pasting in insert mode causes indents to be inserted which isn't usually desirable.
	["<C-v>"] = { "<C-R>+", "Paste the OS register" },
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
	["<C-c>"] = { '"+y', "Copy selection into OS register" },
	["<C-x>"] = { '"+d', "Copy selection into OS register" },
	["<C-s>"] = { '<C-c>:write<cr>', "Save buffer" },
	["<cr>"] = { ":SlimeSend<cr>", "Send current line or selection to SLIME" },
	["f"] = { function()
		local text = getVisualSelection()
		require("telescope.builtin").live_grep({ default_text = text })
	end, "Search for the selected text" },
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

-- Custom mapping to allow for telescope search inside of directories relative to the current buffer.
local function find_buffer_relative_pattern()
	local bufdir = require("telescope.utils").buffer_dir()
	local cwd = vim.fn.getcwd()

	local prompt_title = "Live grep in " .. bufdir

	local i = bufdir:find(cwd)
	if i == 1 then
		local reldir = bufdir:sub(#vim.fn.getcwd() + 1):match("[/]?(.*)")
		if reldir == "" then
			prompt_title = "Live grep"
		else
			prompt_title = "Live grep in " .. reldir
		end
	end

	local search_opts = {
		prompt_title = prompt_title,
		cwd = bufdir,
		initial_mode = "insert",
		selection_strategy = "reset",
	}

	-- Pass opts to find_files
	require("telescope.builtin").live_grep(search_opts)
end

local function cd_to_buf()
	vim.cmd("cd " .. vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
end

-- [[Leader key mappings for all modes]] --
local mappings = {
	["."] = { cd_to_buf, "Change directory to buffer" },
	[','] = { "<cmd>Telescope workspaces<cr>", "Switch workspace" },
	['='] = { "<cmd>Telescope buffers show_all_buffers=true<cr>", "Switch buffer" },
	['+'] = { "<cmd>Telescope oldfiles show_all_buffers=true<cr>", "Find previously opened file" },
	['/'] = { "<cmd>Telescope live_grep<cr>", "Find pattern in files" },
	['*'] = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Find in buffer" },
	['?'] = { find_buffer_relative_pattern, "Find pattern relative to buffer" },
	['%'] = { set_file_ignore_patterns({ ".*_test.go", ".*.feature" }), "Set find ignore pattern" },
	[':'] = { "<cmd>Telescope command_history<cr>", "Command history" },
	['<cr>'] = { "<cmd>split<cr><cmd>resize 24<cr><cmd>term<cr><cmd>set winfixheight<cr>", "Open terminal below" },
	[' '] = { "<cmd>Telescope find_files<cr>", "Find a file" },
	["<tab>"] = { "<cmd>NvimTreeFindFile!<cr>", "Open the file tree" },
	a = {
		name = "Actions",
		["G"] = { "<cmd>!ctags -R<cr>", "Generate tags files recursively" },
		["S"] = { "<cmd>SnippyRestart<cr>", "Refresh the snippet cache" },
		["f"] = { yank_filename, "Copy the current file's name" },
		["h"] = { '<cmd>noh<cr><cmd>let @/ = ""<cr>', "Clear search highlight" },
		["p"] = { yank_filepath, "Copy the current file's path" },
		["v"] = { bib.print, "Print a random Bible verse" },
		['H'] = { "<cmd>checkhealth<cr>", "Check health" },
	},
	b = {
		name = "Buffers",
		["D"] = { bd(true), "Delete buffer (force)" },
		["Q"] = { "<cmd>bdelete!<cr>", "Delete current buffer and window" },
		["R"] = { "<cmd>edit!<cr>", "Reload buffer from file and discard changes" },
		["["] = { "<cmd>bprev<cr>", "Previous buffer" },
		["]"] = { "<cmd>bnext<cr>", "Next buffer" },
		["d"] = { bd(false), "Delete buffer" },
		["l"] = { "<cmd>buffers<cr>", "List buffers" },
		["n"] = { "<cmd>bnext<cr>", "Next buffer" },
		["p"] = { "<cmd>bprev<cr>", "Previous buffer" },
		["r"] = { "<cmd>edit<cr>", "Reload buffer from file" },
		["w"] = { "<cmd>write<cr>", "Write buffer to file" },
		['b'] = { "<cmd>Telescope buffers show_all_buffers=true<cr>", "Find a buffer" },
	},
	c = {
		name = "Configure",
		["g"] = { "<cmd>Gitsigns toggle_linehl<cr>", "Toggle git line highlight" },
		["i"] = { select_indentation, "Pick indentation style" },
		["l"] = { "<cmd>set cursorcolumn!<cr><cmd>set cursorline!<cr>", "Toggle cursor lines" },
		["n"] = { "<cmd>set number!<cr>", "Toggle line numbers" },
		["p"] = { "<cmd>set paste!<cr>", "Toggle paste mode" },
		["t"] = { select_tab_length, "Pick tab length" },
		["w"] = { "<cmd>set list!<cr>", "Toggle visible tabs and trailing whitespace" },
	},
	d = {
		name = "Diagnostics",
		["d"] = { "<cmd>copen<cr>", "Open quickfix list" },
		["k"] = { vim.diagnostic.open_float, "Float diagnostic message under cursor" },
		["l"] = { "<cmd>lopen<cr>", "Open location list" },
		["n"] = { vim.diagnostic.goto_next, "Go to next error" },
		["p"] = { vim.diagnostic.goto_prev, "Go to previous error" },
		-- File information
		["t"] = { "<cmd>set ft?<cr>", "Show current filetype" },
		["j"] = { "<cmd>echo b:terminal_job_id<cr>", "Show terminal job ID" },
	},
	e = {
		name = "Edit",
		["f"] = { format_file, "Format buffer using LSP" },
		["i"] = { "gg=G", "Re-indent buffer" },
		["u"] = { ':%s/\\\\n/\\r/g<cr>', "Unescape newlines" },
		["s"] = { "<cmd>%s/\\s\\+$//e<cr>", "Strip trailing whitespace" },
	},
	f = {
		name = "Find",
		["c"] = { "<cmd>Telescope lsp_incoming_calls<cr>", "Incoming calls of symbol" },
		["d"] = { "<cmd>Telescope lsp_definitions<cr>", "Definitions of symbol" },
		["i"] = { "<cmd>Telescope lsp_implementations<cr>", "Implementations of symbol" },
		["k"] = { vim.lsp.buf.hover, "Show symbol information" },
		["o"] = { "<cmd>Telescope lsp_outgoing_calls<cr>", "outgoing calls of symbol" },
		["r"] = { "<cmd>Telescope lsp_references<cr>", "Find references to the symbol" },
		["s"] = { "<cmd>Telescope lsp_document_symbols<cr>", "Find document symbols" },
		["t"] = { "<cmd>Telescope lsp_type_definitions<cr>", "Find type of symbol" },
		["w"] = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Find workspace symbols" },
	},
	g = {
		name = "Git",
		["A"] = { "<cmd>Git commit --amend<cr>", "Amend commit" },
		["P"] = { "<cmd>Git push<cr>", "Push changes" },
		["U"] = { "<cmd>Git pull<cr>", "Pull changes" },
		["C"] = { "<cmd>Git commit<cr>", "Commit changes" },
		["a"] = { "<cmd>Git blame<cr>", "Show line authors (blame)" },
		["b"] = { "<cmd>Telescope git_branches<cr>", "Switch to branch" },
		["d"] = { "<cmd>Gdiff<cr>", "Diff view" },
		["F"] = { "<cmd>Git fetch<cr>", "Fetch updates" },
		["g"] = { "<cmd>Telescope git_commits<cr>", "Switch to commit" },
		["l"] = { "<cmd>Git log<cr>", "View commit log" },
		["m"] = { "<cmd>Git mergetool<cr>", "Open the merge tool" },
		["s"] = { "<cmd>Git<cr>", "Show status" },
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
	l = {
		name = "LSP",
		-- LSP information and meta-control
		["a"] = { new_toggle(true, toggle_autocomplete), "Toggle autocomplete" },
		["r"] = { "<cmd>LspRestart<cr>", "Restart the language server" },
		["s"] = { "<cmd>LspStart<cr>", "Start LSP" },
		["q"] = { "<cmd>LspStop<cr>", "Stop LSP" },
		["l"] = { "<cmd>LspInfo<cr>", "Show language server information" },
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
		name = "Plugins",
		-- For Packer.nvim
		["u"] = { "<cmd>PackerUpdate<cr>", "Update plugins" },
		["i"] = { "<cmd>PackerInstall<cr>", "Install plugins" },
		["s"] = { "<cmd>PackerSnapshot backup<cr>", "Create plugin backup snapshot" },
		["r"] = { "<cmd>PackerSnapshotRollback backup<cr>", "Rollback to plugin backup snapshot" },
		["c"] = { "<cmd>PackerClean<cr>", "Clean plugins" },
		["y"] = { "<cmd>PackerCompile<cr>", "Compile plugins" },
		-- For Mason.nvim
		["m"] = { "<cmd>Mason<cr>", "Manage Mason packages" },
		["M"] = { "<cmd>MasonUpdate<cr>", "Update Mason registries" },
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
		["n"] = { vim.lsp.buf.rename, "Rename symbol" },
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
	m = {
		name = "Marks",
		["!"] = { "<cmd>delmarks a-zA-Z<cr>", "Delete all marks" },

		["A"] = { "mA", "Set mark A"},
		["a"] = { "'A", "Goto mark A"},

		["B"] = { "mB", "Set mark B"},
		["b"] = { "'B", "Goto mark B"},

		["C"] = { "mC", "Set mark C"},
		["c"] = { "'C", "Goto mark C"},

		["D"] = { "mD", "Set mark D"},
		["d"] = { "'D", "Goto mark D"},
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
		name = "Workspaces",
		["A"] = { "<cmd>WorkspacesAddDir<cr>", "Add directory of workspaces" },
		["R"] = { "<cmd>WorkspacesRemoveDir<cr>", "Remove directory of workspaces" },
		["a"] = { "<cmd>WorkspacesAdd<cr>", "Add workspace" },
		["l"] = { "<cmd>WorkspacesList<cr>", "List workspaces" },
		["n"] = { "<cmd>WorkspacesRename<cr>", "Rename workspace" },
		["p"] = { "<cmd>Telescope workspaces<cr>", "Switch workspace" },
		["r"] = { "<cmd>WorkspacesRemove<cr>", "Remove workspace" },
	},
	y = {
		name = "Testing",
		["a"] = { "<cmd>TestFile<cr>", "Run all tests in file" },
		["c"] = { "<cmd>TestClass<cr>", "Run all tests for current class" },
		["l"] = { "<cmd>TestLast<cr>", "Run last run test" },
		["n"] = { "<cmd>TestNearest<cr>", "Run test nearest to the cursor" },
		["s"] = { "<cmd>TestSuite<cr>", "Run test suite" },
		["v"] = { "<cmd>TestVisit<cr>", "Visit last test file" },
	},
	z = {
		name = "Zettelkasten",
		["p"] = { zet.search, "Find a pattern" },
		["P"] = { zet.search_select, "Find a pattern in selected" },
		["f"] = { zet.find, "Find a note" },
		["F"] = { zet.find_select, "Find a note in selected" },
		["s"] = { zet.select, "Select space" },
		["l"] = { zet.link, "Insert a link to a note" },
		["n"] = { zet.open, "Open a named note" },
		["z"] = { zet.new, "Create a new note" },
		-- Diary specific bindings
		["d"] = { zet.daily, "Open daily entry" },
		["w"] = { zet.weekly, "Open weekly entry" },
		["m"] = { zet.monthly, "Open monthly entry" },
		["y"] = { zet.yearly, "Open yearly entry" },
	},
}

-- Register these mappings for both normal and visual mode.
wk.register(mappings, { mode = "n", prefix = "<leader>" })
