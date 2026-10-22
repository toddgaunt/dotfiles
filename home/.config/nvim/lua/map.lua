-- map.lua contains all custom keybindings

local M = {}

-- map provides an easy to use way to map keybindings.
local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

function M.setup()
	-- Load local modules
	local zet = require("zet")
	local org = require("org")
	local lsp = require("lsp")
	local loc = require("loc")
	-- The util module contains functions that integrate plugins better
	local util = require("util")
	-- gitreview adds a useful git review mode
	local gitreview = require("gitreview")

	-- Load which-key, the best neovim plugin.
	local wk = require('which-key')

	-- Set the leader key to space.
	vim.g.mapleader = " "

	-- opts is a default option set for keybindings
	local default_opts = { noremap = true, silent = true }

	-- Unmap bindings I often fat-finger and would rather use other universal style bindings to perform
	map("n", "u", "", default_opts)  -- Use C-z to undo instead
	map("n", "y", "", default_opts)  -- Use C-c to copy instead
	map("n", "p", "", default_opts)  -- Use C-v to paste instead
	map("n", "<c-r>", "", default_opts) -- use C-y to redo instead
	map("n", "x", "", default_opts)  -- Use delete key to delete characters instead
	map("v", "x", "", default_opts)  -- Use delete key to delete characters instead
	map("v", "y", "", default_opts)  -- Use C-c to copy instead

	-- Unmap unused bindings to free up keys
	map("n", "R", "", default_opts) -- I never use this.
	map("n", "r", "", default_opts) -- I never use this.
	map("n", "Y", "", default_opts) -- Yanking a line can be done with visual mode and 'y', so Y can be bound to something else
	map("n", "t", "", default_opts) -- I never use this.
	map("n", "T", "", default_opts) -- I never use this.
	map("n", "S", "", default_opts) -- I use 'D' then enter insert mode instead of substituting a single line.
	map("n", "s", "", default_opts) -- I never use substitute for a single char

	-- These get bound to window movement, so I don't want any default functionality left on these keys.
	map("n", "<C-h>", "", default_opts)
	map("n", "<C-j>", "", default_opts)
	map("n", "<C-k>", "", default_opts)
	map("n", "<C-l>", "", default_opts)

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
	vim.keymap.set("c", "<C-a>", "<C-b>", { noremap = true })
	vim.keymap.set("c", "<C-b>", "<Left>", { noremap = true })
	vim.keymap.set("c", "<C-f>", "<Right>", { noremap = true })
	vim.keymap.set("c", "<C-c>", function() vim.fn.setreg("+", vim.fn.getcmdline()) end, { noremap = true })
	vim.keymap.set("c", "<C-v>", "<C-r>+", { noremap = true })

	-- [[Visual mode search]] --
	map("v", "/", "<esc>/\\%V", { noremap = true, silent = false })

	-- [[Mouse mappings]] --
	-- Double-click a closed fold to open it, or the first line of an open fold
	-- to close it. Anywhere else keeps the default word selection.
	vim.keymap.set("n", "<2-LeftMouse>", function()
		local lnum = vim.fn.line(".")
		if vim.fn.foldclosed(lnum) ~= -1 then
			return "zo"
		end
		local level = vim.fn.foldlevel(lnum)
		if level > 0 and level > vim.fn.foldlevel(lnum - 1) then
			return "zc"
		end
		return "<2-LeftMouse>"
	end, { expr = true, silent = true })

	-- [[Normal mode mappings]] --
	wk.register({
		['y#'] = { loc.get_loc, "Yank line of code" },
		['y@'] = { util.yank_filename, "Yank file name" },
		["+"] = { "<C-a>", "Increment number" },
		["-"] = { "<C-x>", "Decrement number" },
		["<C-/>"] = { "<cmd>noh<cr><cmd>lua vim.fn.setreg('/', '')<cr>", "Clear search highlight" },
		["<F1>"] = { "<cmd>WhichKey<cr>", "Show keybindings" },
		["<F2>"] = { vim.lsp.buf.rename, "Rename identifier" },
		["<F3>"] = { vim.lsp.buf.references, "Open a list of references" },
		["<F4>"] = { vim.lsp.buf.definition, "Go to definition" },
		["<F5>"] = { util.goto_prev_err, "Go to previous error" },
		["<F6>"] = { util.goto_next_err, "Go to next error" },
		["<F7>"] = { lsp.format_file, "Format buffer" },
		-- Universal shortcuts
		["<C-c>"] = { '"+yy', "Copy line into OS register" },
		["<C-v>"] = { '"+p', "Paste the OS register" },
		["<C-s>"] = { "<cmd>write<cr>", "Save buffer" },
		["<C-z>"] = { "u", "Undo" },
		["<C-y>"] = { "<C-r>", "Redo" },
		["<C-x>"] = { '"+dd', "Cut line" },
		-- Slime
		["<C-space>"] = { "<cmd>SlimeSend<cr>", "Send current line or selection to SLIME" },
		--["<cr>"] = { "<cmd>SlimeSend<cr>", "Send current line or selection to SLIME" },
		["Y"] = { "<cmd>registers<cr>", "Show contents of registers" },
		-- Allow easy movement between softwrapped lines
		["j"] = { "gj", "Down" },
		["k"] = { "gk", "Up" },
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
		["<C-h>"] = { "<C-w>h", "Go to left window" },
		["<C-j>"] = { "<C-w>j", "Go to below window" },
		["<C-k>"] = { "<C-w>k", "Go to above window" },
		["<C-l>"] = { "<C-w>l", "Go to right window" },
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
		["<C-v>"] = { 'c<C-R>+<esc>', "Paste selection from OS register" },
		["<C-x>"] = { '"+d', "Cut selection into OS register" },
		["<C-s>"] = { '<C-c>:write<cr>', "Save buffer" },
		["<C-space>"] = { ":<C-u>call slime#send_op(visualmode(), 1)<cr>", "Send selection to SLIME" },
		--["<cr>"] = { ":'<,'>SlimeSend<cr>", "Send current line or selection to SLIME" },
		["<leader>"] = {
			['#'] = { loc.goto_selected_loc, "Go to selected line of code" },
			["x"] = {
				name = "X.509",
				["x"] = { "!xxd<cr>", "Hex dump" },
				["X"] = { "!xxd -r<cr>", "Reverse hex dump" },
				["c"] = { "!openssl x509 -inform PEM -outform DER | xxd<cr>", "PEM to DER hex dump" },
				["C"] = { "!xxd -r | openssl x509 -inform DER -outform PEM<cr>", "DER hex dump to PEM" },
				["v"] = { "!openssl x509 -noout -text<cr>", "PEM text dump" },
				["o"] = { ":<C-u>s/\\%V, /./g<cr>", "Comma separated integers to OID" },
				["O"] = { ":<C-u>s/\\%V\\./, /g<cr>", "OID to comma separated integers" },
			},
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
			["'"] = { 'c\'<c-r>"\'<esc>', "Surround with '" },
			['"'] = { 'c"<c-r>""<esc>', 'Surround with "' },
			['g'] = {
				name = "Git",
				-- A comment over a range of lines can only be made from visual mode,
				-- so the binding has to exist in both.
				["c"] = { gitreview.comment_line, "Comment on the reviewed lines" },
				["a"] = { function()
					require("gitsigns").stage_hunk({ vim.fn.line("v"), vim.fn.line(".") })
				end, "Stage or unstage selected lines" },
			},
		}
	}, { mode = "v", noremap = true, silent = true })

	-- [[Leader key mappings for all modes]] --
	local mappings = {
		["."] = { util.tcd_to_buf, "Change directory to buffer" },
		[','] = { "<cmd>Telescope buffers show_all_buffers=true<cr>", "Switch buffer" },
		["-"] = { "<cmd>noh<cr><cmd>lua vim.fn.setreg('/', '')<cr>", "Clear search highlight" },
		['#'] = { loc.goto_cursor_loc, "Go to line of code under cursor" },
		['_'] = { "<cmd>Telescope workspaces<cr>", "Open workspace" },
		['/'] = { util.live_grep, "Find pattern in files" },
		["?"] = { util.find_buffer_relative_pattern, "Find pattern relative to buffer" },
		['*'] = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Find in buffer" },
		["'"] = { "<cmd>Telescope marks<cr>", "Find a mark" },
		['%'] = { util.set_file_ignore_patterns({}), "Set file ignore pattern" },
		[':'] = { "<cmd>Telescope command_history<cr>", "Command history" },
		[';'] = { "<cmd>Telescope oldfiles show_all_buffers=true<cr>", "Find previously opened file" },
		['<cr>'] = { "<cmd>split<cr><cmd>resize 8<cr><cmd>term<cr><cmd>set winfixheight<cr>", "Open terminal below" },
		[' '] = { util.find_files, "Find a file" },
		["<tab>"] = { "<cmd>NvimTreeFindFile<cr>", "Open file tree on current buffer" },
		["<C-z>"] = { "<cmd>suspend<cr>", "Suspend process" },
		b = {
			name = "Buffers",
			["Q"] = { "<cmd>bdelete!<cr>", "Delete current buffer and window" },
			['C'] = { util.close_all_invisible_buffers, "Close all invisible buffers" },
			['O'] = { util.close_all_but_current_buffer, "Close all but the current buffer" },
			["d"] = { util.bd(false), "Delete buffer" },
			["l"] = { "<cmd>buffers<cr>", "List buffers" },
			["r"] = { "<cmd>edit<cr>", "Reload buffer from file" },
			["w"] = { "<cmd>write<cr>", "Write buffer to file" },
		},
		c = {
			name = "Config",
			-- Appearance
			["w"] = { "<cmd>set list!<cr>", "Toggle visible whitespace" },
			["n"] = { "<cmd>set number!<cr>", "Toggle line numbers" },
			["l"] = { "<cmd>set cursorcolumn!<cr><cmd>set cursorline!<cr>", "Toggle cursor lines" },
			["g"] = { "<cmd>Gitsigns toggle_linehl<cr>", "Toggle git line highlight" },

			-- Behavior
			["i"] = { util.select_indentation, "Pick indentation style" },
			["p"] = { "<cmd>set paste!<cr>", "Toggle paste mode" },
			["t"] = { util.select_tab_length, "Pick tab length" },
			["e"] = { util.set_env_var(), "Set environment variable" },

			-- Actions
			["R"] = { "<cmd>restart<cr>", "Restart Neovim (reload config)" },
		},
		d = {
			name = "Diagnostics",
			["d"] = { "<cmd>copen<cr>", "Open quickfix list" },
			["n"] = { "<cmd>cn<cr>", "Next quickfix location" },
			["p"] = { "<cmd>cp<cr>", "Previous quickfix location" },
			["k"] = { vim.diagnostic.open_float, "Float diagnostic message under cursor" },
			["l"] = { "<cmd>lopen<cr>", "Open location list" },
			["["] = { util.goto_prev_err, "Go to previous error" },
			["]"] = { util.goto_next_err, "Go to next error" },
		},
		g = {
			name = "Git",
			[","] = { "<cmd>Telescope git_branches<cr>", "Switch to branch" },
			["A"] = { "<cmd>Git commit --amend<cr>", "Amend commit" },
			["C"] = { "<cmd>Git commit<cr>", "Commit changes" },
			["B"] = { "<cmd>Git blame<cr>", "Show line authors (blame)" },
			["a"] = { function() require("gitsigns").stage_hunk() end, "Stage or unstage hunk" },
			["c"] = { gitreview.comment_line, "Comment on the reviewed line" },
			["d"] = { "<cmd>Git diff --staged<cr>", "Show staged diff" },
			["F"] = { "<cmd>Git fetch<cr>", "Fetch updates" },
			["g"] = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
			["l"] = { "<cmd>Git log<cr>", "View commit log" },
			["P"] = { "<cmd>Git push<cr>", "Push changes" },
			["r"] = { gitreview.select_branch, "Review against selected branch" },
			["s"] = { "<cmd>Git<cr>", "Show status" },
			["U"] = { "<cmd>Git pull<cr>", "Pull changes" },
			["w"] = { "<cmd>Gwrite<cr>", "Stage file" },
		},
		h = {
			name = "Help",
			["a"] = { "<cmd>Telescope autocommands<cr>", "Search autocommands" },
			["g"] = { "<cmd>Telescope highlights<cr>", "Search highlight groups" },
			["h"] = { "<cmd>Telescope help_tags<cr>", "Search help page" },
			["k"] = { "<cmd>Telescope keymaps<cr>", "Search key maps" },
			["m"] = { "<cmd>Telescope man_pages<cr>", "Search man pages" },
			["o"] = { "<cmd>Telescope vim_options<cr>", "Search config options" },
			["w"] = { "<cmd>WhichKey<cr>", "Show which-key help" },
		},
		i = {
			name = "Identifiers",
			["c"] = { "<cmd>Telescope lsp_incoming_calls<cr>", "Incoming calls of identifier" },
			["d"] = { "<cmd>Telescope lsp_definitions<cr>", "Definitions of identifier" },
			["i"] = { "<cmd>Telescope lsp_implementations<cr>", "Implementations of identifier" },
			["o"] = { "<cmd>Telescope lsp_outgoing_calls<cr>", "Outgoing calls of identifier" },
			["r"] = { "<cmd>Telescope lsp_references<cr>", "References to the identifier" },
			["s"] = { "<cmd>Telescope lsp_document_symbols<cr>", "Document identifiers" },
			["t"] = { "<cmd>Telescope lsp_type_definitions<cr>", "Type of identifier" },
			["w"] = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace identifiers" },
		},
		k = {
			name = "Inspect",
			["t"] = { "<cmd>set ft?<cr>", "Show current filetype" },
			["j"] = { "<cmd>echo b:terminal_job_id<cr>", "Show terminal job ID" },
			["b"] = { util.print_buf_name, "Show current buffer name" },
			["i"] = { "<cmd>Inspect<cr>", "Show highlight group" },
			["k"] = { vim.lsp.buf.hover, "Show identifier information" },
		},
		l = {
			name = "LSP",
			-- LSP information and meta-control
			["a"] = { util.toggle_autocomplete(true), "Toggle autocomplete (buffer)" },
			["r"] = { lsp.restart, "Restart all language servers" },
			["x"] = { lsp.stop, "Stop all language servers" },
			["s"] = { "<cmd>LspInfo<cr>", "Show language server status" },
			["l"] = { "<cmd>LspLog<cr>", "Show language server log" },
			["G"] = { "<cmd>!ctags -R<cr>", "Generate ctags files recursively" },
			["S"] = { "<cmd>SnippyReload<cr>", "Refresh the snippet cache" },
			["m"] = { "<cmd>Mason<cr>", "Manage Mason packages" },
		},
		o = {
			name = "Organize",
			["c"] = { org.cancel_task, "Mark a task as cancelled" },
			["h"] = { 'o<Esc>"=strftime("# %Y.%m.%d %a")<cr>P', "Create a date heading" },
			["e"] = { org.create_deadline, "Add deadline to a task" },
			["p"] = { org.mark_task_in_progress, "Mark a task as in progress" },
			["o"] = { org.mark_task_unfinished, "Mark a task as unfinished" },
			["t"] = { org.insert_task, "Insert a task below" },
			["T"] = { function() org.insert_task({ above = true }) end, "Insert a task above" },
			["x"] = { org.mark_task_finished, "Mark a task as finished" },
			["<"] = { org.mark_task_rescheduled, "Mark a task as rescheduled" },
			[">"] = { org.mark_task_migrated, "Mark a task as migrated" },
			["s"] = { 'o<Esc>"=strftime("<%Y.%m.%d %a>")<cr>P', "Add a timestamp" },
		},
		p = {
			name = "Plugins",
			-- vim.pack.update shows the changes in a new tab: :write applies them, :quit discards them.
			["u"] = { function() vim.pack.update() end, "Update plugins" },
			["l"] = { function() vim.pack.update(nil, { offline = true }) end, "List installed plugins" },
			["r"] = { function() vim.pack.update(nil, { target = "lockfile" }) end, "Revert plugins to the lockfile" },
			['h'] = { "<cmd>checkhealth<cr>", "Check health" },
		},
		q = {
			name = "Workspaces",
			["Q"] = { "<cmd>qa<cr>", "Quit all" },
			["A"] = { "<cmd>WorkspacesAddDir<cr>", "Add workspace directory" },
			["R"] = { "<cmd>WorkspacesRemoveDir<cr>", "Remove workspace directory" },
			["a"] = { "<cmd>WorkspacesAdd<cr>", "Add workspace" },
			["w"] = { "<cmd>WorkspacesList<cr>", "List workspaces" },
			["n"] = { util.workspace_rename, "Rename workspace" },
			["r"] = { "<cmd>WorkspacesRemove<cr>", "Remove workspace" },
		},
		r = {
			name = "Refactor",
			["a"] = { vim.lsp.buf.code_action, "Show code actions" },
			["n"] = { vim.lsp.buf.rename, "Rename identifier" },
			["i"] = { "gg=G", "Re-indent buffer" },
			["u"] = { ':%s/\\\\n/\\r/g<cr>', "Unescape newlines" },
			["s"] = { "<cmd>%s/\\s\\+$//e<cr>", "Strip trailing whitespace" },
			["f"] = { lsp.format_file, "Format buffer" },
		},
		s = {
			name = "Spelling",
			["a"] = { "zg", "Add word to dictionary" },
			["]"] = { "]s", "Go to next spelling error" },
			["["] = { "[s", "Go to previous spelling error" },
			["s"] = { util.toggle_spellcheck, "Toggle spell check" },
			["w"] = { "zw", "Mark word as bad spelling" },
			["z"] = { "z=", "Suggest spelling correction" },
		},
		t = {
			name = "Testing",
			["a"] = { "<cmd>TestFile<cr>", "Run all tests in file" },
			["c"] = { "<cmd>TestClass<cr>", "Run all tests for current class" },
			["l"] = { "<cmd>TestLast<cr>", "Rerun last test" },
			["n"] = { "<cmd>TestNearest<cr>", "Run test nearest to the cursor" },
			["s"] = { "<cmd>TestSuite<cr>", "Run test suite" },
			["v"] = { "<cmd>TestVisit<cr>", "Visit last test file" },
		},
		w = {
			name = "Windows",
			["="] = { "<C-w>=", "Equalize window size" },
			["O"] = { "<cmd>tabonly<cr>", "Close all other tabs" },
			["Q"] = { "<cmd>tabclose<cr>", "Close current tab" },
			["s"] = { "<C-w>s", "Split horizontal" },
			["t"] = { "<cmd>tabnew<cr>", "Open a new tab" },
			["T"] = { "<C-w>T", "Move window into a new tab" },
			["v"] = { "<C-w>v", "Split vertical" },
			["x"] = { "<C-w>x", "Swap with other window" },
			["a"] = { "<C-w>|", "Max out window width" },
			["z"] = { "<C-w>_", "Max out window height" },
		},
		z = {
			name = "Zettelkasten",
			["."] = { zet.cd_to_current_collection, "Change directory to collection" },
			["p"] = { zet.search, "Find a pattern in a note" },
			["f"] = { zet.find, "Find a note" },
			["s"] = { zet.select, "Select space" },
			["l"] = { zet.link, "Insert a link to a note" },
			["n"] = { zet.find_open, "Open or create a named collection" },
			["z"] = { zet.new, "Create a new note" },
			-- Diary specific bindings
			["d"] = { zet.daily, "Open daily entry" },
			["m"] = { zet.monthly, "Open monthly entry" },
			["y"] = { zet.yearly, "Open yearly entry" },
			["t"] = { zet.todo, "Open the TODO list" },
			["["] = { zet.prev, "Open previous entry" },
			["]"] = { zet.next, "Open next entry" },
		},
	}

	wk.register(mappings, { mode = "n", prefix = "<leader>" })
end

return M
