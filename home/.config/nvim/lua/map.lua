-- map.lua contains all custom keybindings

local M = {}

-- map provides an easy to use way to map keybindings.
local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

function M.setup()
	-- Load local modules
	local zet = require("zet")
	local org = require("org")
	local bib = require("bib")
	local lsp = require("lsp")

	-- The util module contains functions that integrate plugins better
	local util = require("util")

	-- Load which-key, the best neovim plugin.
	local wk = require('which-key')

	-- Set the leader key to space.
	vim.g.mapleader = " "

	-- opts is a default option set for keybindings
	local default_opts = { noremap = true, silent = true }

	-- Unmap unused bindings to free up keys
	map("n", "R", "", default_opts) -- I never use this.
	map("n", "r", "", default_opts) -- I never use this.
	map("n", "Y", "", default_opts) -- Yanking a line can be done with visual mode and 'y', so Y can be bound to something else
	map("n", "t", "", default_opts) -- I never use this.
	map("n", "T", "", default_opts) -- I never use this.
	map("n", "S", "", default_opts) -- I use 'D' then enter insert mode instead of substituting a single line.
	map("n", "s", "", default_opts) -- I never use substitute for a single char

	--[[Terminal mode mappings]]
	map("t", "<Esc>", "<C-\\><C-N>", default_opts)
	map("t", "<S-Space>", "<Space>", default_opts)
	map("t", "<S-BS>", "<BS>", default_opts)
	map("t", "<S-CR>", "<CR>", default_opts)
	map("t", "<C-S-C>", '<C-\\><C-N>"+yi', default_opts)
	map("t", "<C-S-V>", '<C-\\><C-N>"+pi', default_opts)
	map("t", "<C-V>", '<C-\\><C-N>"+pi', default_opts)

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
		["<F7>"] = { util.format_file, "Format file" },
		["<C-q>"] = { "<cmd>bdelete!<cr>", "Close current buffer" },
		-- Universal shortcuts
		["<C-c>"] = { '"+yy', "Copy selection into OS register" },
		["<C-v>"] = { '"+p', "Paste the OS register" },
		["<C-s>"] = { "<cmd>write<cr>", "Save buffer" },
		["<C-x>"] = { "<cmd>Inspect<cr>", "inspect identifier" },
		["<C-f>"] = { "/", "Search forward" },
		["<C-S-f>"] = { "?", "Search backward" },
		-- Slime
		["<C-space>"] = { "<cmd>SlimeSend<cr>", "Send current line or selection to SLIME" },
		["<cr>"] = { "<cmd>SlimeSend<cr>", "Send current line or selection to SLIME" },
		["Y"] = { "<cmd>registers<cr>", "Show contents of registers" },
		-- Allow easy movement between softwrapped lines
		["j"] = { "gj", "Down" },
		["k"] = { "gk", "Up" },
		-- Leap plugin movement
		["s"] = { "<Plug>(leap-forward-to)", "Leap forward" },
		["S"] = { "<Plug>(leap-backward-to)", "Leap backward" },
		-- Emacs movement since it is so ingrained
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
		["<C-space>"] = { ":SlimeSend<cr>", "Send current line or selection to SLIME" },
		["<cr>"] = { ":SlimeSend<cr>", "Send current line or selection to SLIME" },
		["<leader>"] = {
			['/'] = { function()
				local text = util.get_visual_selection()
				util.live_grep({ default_text = text })
			end, "Search for selected text" },
			[' '] = { function()
				local text = util.get_visual_selection()
				util.find_files({ default_text = text })
			end, "Search for selected file" },
			[':'] = { function()
				local text = util.get_visual_selection()
				require("telescope.builtin").command_history({ default_text = text })
			end, "Search for selected command" },
			['*'] = { function()
				local text = util.get_visual_selection()
				require("telescope.builtin").current_buffer_fuzzy_find({ default_text = text })
			end, "Search buffer for selected text" },
		}
	}, { mode = "v", noremap = true, silent = true })

	-- [[Leader key mappings for all modes]] --
	local mappings = {
		["."] = { util.cd_to_buf, "Change directory to buffer" },
		['_'] = { "<cmd>Telescope workspaces<cr>", "Switch workspace" },
		['='] = { "<cmd>Telescope buffers show_all_buffers=true<cr>", "Switch buffer" },
		['/'] = { util.live_grep, "Find pattern in files" },
		['*'] = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Find in buffer" },
		["'"] = { "<cmd>Telescope marks<cr>", "Find a mark" },
		['%'] = { util.set_file_ignore_patterns({}), "Set find ignore pattern" },
		[':'] = { "<cmd>Telescope command_history<cr>", "Command history" },
		['<cr>'] = { "<cmd>split<cr><cmd>resize 24<cr><cmd>term<cr><cmd>set winfixheight<cr>", "Open terminal below" },
		[' '] = { util.find_files, "Find a file" },
		["<tab>"] = { "<cmd>NvimTreeFindFile!<cr>", "Open the file tree" },
		a = {
			name = "Actions",
			['c'] = { "<cmd>checkhealth<cr>", "Check health" },
			["h"] = { '<cmd>noh<cr><cmd>let @/ = ""<cr>', "Clear search highlight" },
			["v"] = { bib.insert, "Insert a random Bible verse below" },
			["V"] = { function() bib.insert({ above = true }) end, "Insert a random Bible verse above" },
			["G"] = { "<cmd>!ctags -R<cr>", "Generate tags files recursively" },
			["S"] = { "<cmd>SnippyRestart<cr>", "Refresh the snippet cache" },
			["r"] = { "<cmd>luafile $MYVIMRC<cr>", "Reload config"},
		},
		b = {
			name = "Buffers",
			["D"] = { util.bd(true), "Delete buffer (force)" },
			["Q"] = { "<cmd>bdelete!<cr>", "Delete current buffer and window" },
			["R"] = { "<cmd>edit!<cr>", "Reload buffer from file and discard changes" },
			["["] = { "<cmd>bprev<cr>", "Previous buffer" },
			["]"] = { "<cmd>bnext<cr>", "Next buffer" },
			["d"] = { util.bd(false), "Delete buffer" },
			["l"] = { "<cmd>buffers<cr>", "List buffers" },
			["r"] = { "<cmd>edit<cr>", "Reload buffer from file" },
			["w"] = { "<cmd>write<cr>", "Write buffer to file" },
			['b'] = { "<cmd>Telescope buffers show_all_buffers=true<cr>", "Find a buffer" },
			['o'] = { util.close_all_invisible_buffers, "Close all invisible buffers"},
			['O'] = { util.close_all_but_current_buffer, "Close all but the current buffer" },
			['#'] = { util.get_loc, "Yank line of code" },
			['@'] = { util.yank_filename, "Yank file name" },
		},
		c = {
			name = "Config",

			-- Appearance
			["w"] = { "<cmd>set list!<cr>", "Toggle visible tabs and trailing whitespace" },
			["h"] = { "<cmd>TSBufToggle highlight", "Toggle syntax highlighting for the buffer" },
			["n"] = { "<cmd>set number!<cr>", "Toggle line numbers" },
			["l"] = { "<cmd>set cursorcolumn!<cr><cmd>set cursorline!<cr>", "Toggle cursor lines" },
			["g"] = { "<cmd>Gitsigns toggle_linehl<cr>", "Toggle git line highlight" },

			-- Behavior
			["i"] = { util.select_indentation, "Pick indentation style" },
			["p"] = { "<cmd>set paste!<cr>", "Toggle paste mode" },
			["t"] = { util.select_tab_length, "Pick tab length" },
			["e"] = { util.set_env_var(), "Set environment variable"},
		},
		d = {
			name = "Debug",
			["d"] = { "<cmd>copen<cr>", "Open quickfix list" },
			["k"] = { vim.diagnostic.open_float, "Float diagnostic message under cursor" },
			["l"] = { "<cmd>lopen<cr>", "Open location list" },
			["["] = { vim.diagnostic.goto_prev, "Go to previous error" },
			["]"] = { vim.diagnostic.goto_next, "Go to next error" },
			["b"] = { "<cmd>DlvAddBreakpoint<cr>", "Set delve breakpoint" },
		},
		f = {
			name = "Files",
			["f"] = { util.find_files, "Find a file" },
			["o"] = { "<cmd>Telescope oldfiles show_all_buffers=true<cr>", "Find previously opened file" },
			["p"] = { util.live_grep, "Find pattern in files" },
			["r"] = { util.find_buffer_relative_pattern, "Find pattern relative to buffer" },
			["t"] = { "<cmd>NvimTreeToggle<cr>", "Toggle the file tree" },
		},
		g = {
			name = "Git",
			["A"] = { "<cmd>Git commit --amend<cr>", "Amend commit" },
			["P"] = { "<cmd>Git push<cr>", "Push changes" },
			["U"] = { "<cmd>Git pull<cr>", "Pull changes" },
			["c"] = { "<cmd>Git diff --staged<cr>", "Show staged diff" },
			["C"] = { "<cmd>Git commit<cr>", "Commit changes" },
			["a"] = { "<cmd>Git blame<cr>", "Show line authors (blame)" },
			["b"] = { "<cmd>Telescope git_branches<cr>", "Switch to branch" },
			["d"] = { function() util.git_diff("Gvdiffsplit") end, "Diff against branch" },
			["D"] = { util.git_diff_select_branch, "Select a diff branch" },
			["F"] = { "<cmd>Git fetch<cr>", "Fetch updates" },
			["g"] = { "<cmd>Telescope git_commits<cr>", "Switch to commit" },
			["l"] = { "<cmd>Git log<cr>", "View commit log" },
			["m"] = { "<cmd>Git mergetool<cr>", "Open the merge tool" },
			["s"] = { "<cmd>Git<cr>", "Show status" },
			["w"] = { "<cmd>Gwrite<cr>", "Write changes in buffer" },
			["r"] = { function() util.git_list_diff_files() end, "Review changed files" },
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
			name = "Identifiers",
			["c"] = { "<cmd>Telescope lsp_incoming_calls<cr>", "Incoming calls of identifer" },
			["d"] = { "<cmd>Telescope lsp_definitions<cr>", "Definitions of identifer" },
			["i"] = { "<cmd>Telescope lsp_implementations<cr>", "Implementations of identifer" },
			["k"] = { vim.lsp.buf.hover, "Show identifer information" },
			["o"] = { "<cmd>Telescope lsp_outgoing_calls<cr>", "Outgoing calls of identifer" },
			["r"] = { "<cmd>Telescope lsp_references<cr>", "Find references to the identifer" },
			["s"] = { "<cmd>Telescope lsp_document_symbols<cr>", "Find document identifers" },
			["t"] = { "<cmd>Telescope lsp_type_definitions<cr>", "Find type of identifier" },
			["w"] = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Find workspace identifiers" },
			["j"] = { "<C-]>", "Jump to definition" },
			["l"] = { "<C-t>", "Jump back" },
		},
		k = {
			name = "Inspect",
			["t"] = { "<cmd>set ft?<cr>", "Show current filetype" },
			["j"] = { "<cmd>echo b:terminal_job_id<cr>", "Show terminal job ID" },
			["b"] = { util.print_buf_name, "Show current buffer name" },
			["i"] = { "<cmd>Inspect<cr>", "Inspect identifier" },
		},
		l = {
			name = "LSP",
			-- LSP information and meta-control
			["a"] = { util.toggle_autocomplete, "Toggle autocomplete" },
			["r"] = { "<cmd>LspRestart<cr>", "Restart the language server" },
			["s"] = { "<cmd>LspStop<cr>", "Stop LSP" },
			["i"] = { "<cmd>LspInfo<cr>", "Show language server information" },
			["c"] = { util.copilot_status, "Show Github Copilot status"},
			["C"] = { util.copilot_toggle, "Toggle Github Copilot for buffer"},
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
		},
		p = {
			name = "Plugins",
			["u"] = { "<cmd>PackerUpdate<cr>", "Update plugins" },
			["i"] = { "<cmd>PackerInstall<cr>", "Install plugins" },
			["s"] = { "<cmd>PackerSnapshot backup<cr>", "Create plugin backup snapshot" },
			["r"] = { "<cmd>PackerSnapshotRollback backup<cr>", "Rollback to plugin backup snapshot" },
			["c"] = { "<cmd>PackerClean<cr>", "Clean plugins" },
			["y"] = { "<cmd>PackerCompile<cr>", "Compile plugins" },
			["m"] = { "<cmd>Mason<cr>", "Manage Mason packages" },
		},
		q = {
			name = "Sessions",
			["Q"] = { "<cmd>qa<cr>", "Quit all" },
			["d"] = { "<cmd>SessionsStop<cr>", "Stop session" },
			["l"] = { "<cmd>SessionsLoad<cr>", "Load session" },
			["s"] = { "<cmd>SessionsSave<cr>", "Save session" },
		},
		r = {
			name = "Refactor",
			["a"] = { vim.lsp.buf.code_action, "Open action list" },
			["n"] = { vim.lsp.buf.rename, "Rename symbol" },
			["i"] = { "gg=G", "Re-indent buffer" },
			["u"] = { ':%s/\\\\n/\\r/g<cr>', "Unescape newlines" },
			["s"] = { "<cmd>%s/\\s\\+$//e<cr>", "Strip trailing whitespace" },
			["f"] = { lsp.format_file, "Format buffer using LSP" },
		},
		s = {
			name = "Spellcheck",
			["a"] = { "zg", "Add word to dictionary" },
			["]"] = { "]s", "Go to next spelling error" },
			["["] = { "[s", "Go to previous spelling error" },
			["s"] = { util.toggle_spellcheck, "Toggle spell check" },
			["w"] = { "zw", "Mark word as bad spelling" },
			["z"] = { "z=", "Suggest spelling correction" },
		},
		t = {
			name = "Tabs",
			["h"] = { "<cmd>-tabnext<cr>", "Go to the next tab" },
			["l"] = { "<cmd>+tabnext<cr>", "Go to the previous tab" },
			["["] = { "<cmd>-tabnext<cr>", "Go to the previous tab" },
			["]"] = { "<cmd>+tabnext<cr>", "Go to the next tab" },
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
			name = "Workspaces",
			["A"] = { "<cmd>WorkspacesAddDir<cr>", "Add directory" },
			["R"] = { "<cmd>WorkspacesRemoveDir<cr>", "Remove directory" },
			["a"] = { "<cmd>WorkspacesAdd<cr>", "Add workspace" },
			["f"] = { "<cmd>Telescope workspaces<cr>", "Find workspace" },
			["l"] = { "<cmd>WorkspacesList<cr>", "List workspaces" },
			["n"] = { util.workspace_rename, "Rename workspace" },
			["r"] = { "<cmd>WorkspacesRemove<cr>", "Remove workspace" },
			["s"] = { util.workspace_select, "Select workspace" },
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
			["c"] = { zet.select, "Select a note-space" },
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
			["["] = { zet.prev, "Open previous entry" },
			["]"] = { zet.next, "Open next entry" },
		},
	}

	-- Register these mappings for both normal and visual mode.
	wk.register(mappings, { mode = "n", prefix = "<leader>" })
end

return M
