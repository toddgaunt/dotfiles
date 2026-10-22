-- Plugins are managed by vim.pack and pinned to a commit. Their exact revisions
-- are also recorded in nvim-pack-lock.json, which is installed from on a new machine.
local function gh(repo) return "https://github.com/" .. repo end

local function install_plugins()
	-- mason installs language servers and other tools
	vim.pack.add({
		{ src = gh("williamboman/mason.nvim"), version = "197f6352c276bbc2d25541dfce00ec50d1a4e88f" }, -- v2.2.1
	})
	require("mason").setup()

	-- which-key is the best keybinding plugin ever
	vim.pack.add({
		{ src = gh("folke/which-key.nvim"), version = "0539da005b98b02cf730c1d9da82b8e8edb1c2d2" }, -- v2.1.0
	})
	vim.opt.timeout = true
	vim.opt.timeoutlen = 0
	require('which-key').setup {
		sort_by_description = true,
	}

	-- vim-lastplace remembers my last cursor position in files
	vim.pack.add({
		{ src = gh("farmergreg/vim-lastplace"), version = "17b69463aa384b990a8d45e4fd241f446ac0be1e" }, -- v4.4.0
	})

	-- nvim-web-devicons provides the icons used by luatab and nvim-tree
	vim.pack.add({ gh("nvim-tree/nvim-web-devicons") })

	-- luatab provides a better tab bar
	vim.pack.add({
		{ src = gh("alvarosevilla95/luatab.nvim"), version = "7ac54b014b542f02a73b62fcae65db7a2382a378" },
	})
	require("luatab").setup()

	-- nvim-scrollbar shows a scrollbar with diagnostic and cursor marks
	vim.pack.add({
		{ src = gh("petertriho/nvim-scrollbar"), version = "f8e87b96cd6362ef8579be456afee3b38fd7e2a8" }, -- v1.0.0
	})
	require("scrollbar").setup()

	-- gitsigns adds git status symbols in the gutter
	vim.pack.add({
		{ src = gh("lewis6991/gitsigns.nvim"), version = "7010000889bfb6c26065e0b0f7f1e6aa9163edd9" }, -- v1.0.2
	})
	require("gitsigns").setup()
	require("scrollbar.handlers.gitsigns").setup()

	-- mini.bufremove maintains window layout when deleting a buffer
	vim.pack.add({
		{ src = gh("echasnovski/mini.bufremove"), version = "66019ecebdc5bc0759e04747586994e2e3f98416" }, -- v0.16.0
	})
	require("mini.bufremove").setup()

	-- nvim-tree provides a file-explorer tree with icon support
	vim.pack.add({
		{ src = gh("nvim-tree/nvim-tree.lua"), version = "321bc61580fd066b76861c32de3319c3a6d089e7" }, -- v1.16.0
	})
	require("nvim-tree").setup({
		sync_root_with_cwd = true,
		respect_buf_cwd = false,
		update_focused_file = {
			enable = false,
		},
		diagnostics = {
			enable = true,
			show_on_dirs = true,
			show_on_open_dirs = true,
		},
		filters = {
			git_ignored = false,
			dotfiles = false,
			git_clean = false,
			no_buffer = false,
			no_bookmark = false,
			custom = {},
			exclude = {},
		},
		view = {
			preserve_window_proportions = true,
			signcolumn = "yes",
			float = {
				enable = false,
			},
		},
		renderer = {
			indent_markers = {
				enable = true,
				inline_arrows = true,
				icons = {
					corner = "└",
					edge = "│",
					item = "│",
					bottom = "─",
					none = " ",
				},
			},
		},
		sort = {
			sorter = nil,
			folders_first = true,
			files_first = false,
		},
		on_attach = function(bufnr)
			local api = require('nvim-tree.api')

			local function opts(desc)
				return {
					desc = 'nvim-tree: ' .. desc,
					buffer = bufnr,
					noremap = true,
					silent = true,
					nowait = true
				}
			end

			-- Default mappings. Feel free to modify or remove as you wish.
			vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node, opts('CD'))
			vim.keymap.set('n', '<C-e>', api.node.open.replace_tree_buffer, opts('Open: In Place'))
			vim.keymap.set('n', 'K', api.node.show_info_popup, opts('Info'))
			vim.keymap.set('n', '<C-r>', api.fs.rename_sub, opts('Rename: Omit Filename'))
			vim.keymap.set('n', '<C-t>', api.node.open.tab, opts('Open: New Tab'))
			vim.keymap.set('n', 't', api.node.open.tab, opts('Open: New Tab'))
			vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
			vim.keymap.set('n', '<C-x>', api.node.open.horizontal, opts('Open: Horizontal Split'))
			vim.keymap.set('n', '<BS>', api.node.navigate.parent_close, opts('Close Directory'))
			vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
			vim.keymap.set('n', '<Tab>', api.node.open.preview, opts('Open Preview'))
			vim.keymap.set('n', '>', api.node.navigate.sibling.next, opts('Next Sibling'))
			vim.keymap.set('n', '<', api.node.navigate.sibling.prev, opts('Previous Sibling'))
			vim.keymap.set('n', '.', api.node.run.cmd, opts('Run Command'))
			vim.keymap.set('n', '-', api.tree.change_root_to_parent, opts('Up'))
			vim.keymap.set('n', 'a', api.fs.create, opts('Create'))
			vim.keymap.set('n', 'M', api.marks.bulk.move, opts('Move Bookmarked'))
			vim.keymap.set('n', 'HB', api.tree.toggle_no_buffer_filter, opts('Toggle No Buffer'))
			vim.keymap.set('n', 'c', api.fs.copy.node, opts('Copy'))
			vim.keymap.set('n', 'C', api.tree.toggle_git_clean_filter, opts('Toggle Git Clean'))
			vim.keymap.set('n', '[c', api.node.navigate.git.prev, opts('Prev Git'))
			vim.keymap.set('n', ']c', api.node.navigate.git.next, opts('Next Git'))
			vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
			vim.keymap.set('n', 'D', api.fs.trash, opts('Trash'))
			vim.keymap.set('n', 'E', api.tree.expand_all, opts('Expand All'))
			vim.keymap.set('n', 'e', api.fs.rename_basename, opts('Rename: Basename'))
			vim.keymap.set('n', ']e', api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
			vim.keymap.set('n', '[e', api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
			vim.keymap.set('n', 'F', api.live_filter.clear, opts('Clean Filter'))
			vim.keymap.set('n', 'f', api.live_filter.start, opts('Filter'))
			vim.keymap.set('n', 'g?', api.tree.toggle_help, opts('Help'))
			vim.keymap.set('n', 'gy', api.fs.copy.absolute_path, opts('Copy Absolute Path'))
			vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts('Toggle Dotfiles'))
			vim.keymap.set('n', 'I', api.tree.toggle_gitignore_filter, opts('Toggle Git Ignore'))
			-- These default mappings are disabled so they don't conflict with my window movement bindings.
			--vim.keymap.set('n', '<C-j>', api.node.navigate.sibling.last, opts('Last Sibling'))
			--vim.keymap.set('n', '<C-k>', api.node.navigate.sibling.first, opts('First Sibling'))
			vim.keymap.set('n', 'm', api.marks.toggle, opts('Toggle Bookmark'))
			vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
			vim.keymap.set('n', 'O', api.node.open.no_window_picker, opts('Open: No Window Picker'))
			vim.keymap.set('n', 'p', api.fs.paste, opts('Paste'))
			vim.keymap.set('n', 'P', api.node.navigate.parent, opts('Parent Directory'))
			vim.keymap.set('n', 'q', api.tree.close, opts('Close'))
			vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))
			vim.keymap.set('n', 'R', api.tree.reload, opts('Refresh'))
			vim.keymap.set('n', 's', api.node.run.system, opts('Run System'))
			vim.keymap.set('n', 'S', api.tree.search_node, opts('Search'))
			vim.keymap.set('n', 'U', api.tree.toggle_custom_filter, opts('Toggle Hidden'))
			vim.keymap.set('n', 'W', api.tree.collapse_all, opts('Collapse'))
			vim.keymap.set('n', 'x', api.fs.cut, opts('Cut'))
			vim.keymap.set('n', 'y', api.fs.copy.filename, opts('Copy Name'))
			vim.keymap.set('n', 'Y', api.fs.copy.relative_path, opts('Copy Relative Path'))
			vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts('Open'))
			vim.keymap.set('n', '<2-RightMouse>', api.tree.change_root_to_node, opts('CD'))

			-- The dummy mapping set before calling vim.keymap.del is done for safety,
			-- in case a default mapping does not exist.
			vim.keymap.set('n', '<C-e>', '', { buffer = bufnr })
			vim.keymap.del('n', '<C-e>', { buffer = bufnr })

			vim.keymap.set('n', '<C-a>', '', { buffer = bufnr })
			vim.keymap.del('n', '<C-a>', { buffer = bufnr })

			vim.keymap.set('n', '<C-p>', '', { buffer = bufnr })
			vim.keymap.del('n', '<C-p>', { buffer = bufnr })

			vim.keymap.set('n', '<c-n>', '', { buffer = bufnr })
			vim.keymap.del('n', '<c-n>', { buffer = bufnr })
		end,
		actions = {
			open_file = {
				window_picker = {
					-- Any windows which contain excluded type won't be available to pick from nvim-tree.
					exclude = {
						filetype = { "notify", "nvim-pack", "qf", "diff", "fugitive", "fugitiveblame", },
						buftype  = { "help", "terminal", "minimap" },
					},
				},
			},
		},
	})

	-- telescope is a very powerful fuzzy finder with a great UI
	-- NOTE: telescope-fzf-native is never built (it needs `make`) or loaded as an extension.
	vim.pack.add({
		{ src = gh("nvim-lua/plenary.nvim"),                    version = "08e301982b9a057110ede7a735dd1b5285eb341f" },
		{ src = gh("nvim-telescope/telescope-fzf-native.nvim"), version = "9ef21b2e6bb6ebeaf349a0781745549bbb870d27" },
		{ src = gh("nvim-telescope/telescope.nvim"),            version = "a0bbec21143c7bc5f8bb02e0005fa0b982edc026" }, -- 0.1.8
	})
	local actions = require('telescope.actions')
	require("telescope").setup({
		defaults = {
			wrap_results = true,
			dynamic_preview_title = true,
			preview = {
				hide_on_startup = false,
			},
			mappings = {
				i = {
					["<C-c>"] = actions.smart_send_to_qflist + actions.open_qflist,
				},
			},
		},
	})

	-- session management makes switching projects easier
	vim.pack.add({
		{ src = gh("natecraddock/sessions.nvim"), version = "f13158483e0b6255c6dfe473145ce4ee3495d844" },
	})
	require("sessions").setup({
		events = { "VimLeavePre" },
		session_filepath = vim.fn.stdpath("data") .. "/sessions",
		absolute = true,
	})

	-- workspaces allows for easily changing between projects
	vim.pack.add({
		{ src = gh("natecraddock/workspaces.nvim"), version = "55a1eb6f5b72e07ee8333898254e113e927180ca" },
	})
	require("workspaces").setup({
		hooks = {
			open_pre = {
				"SessionsStop",
				"silent %bdelete!",
			},

			open = function()
				require("sessions").load(nil, {})
				require("nvim-tree.api").tree.toggle()
			end,
		}
	})
	require("telescope").load_extension("workspaces")

	-- vim-slime makes REPL development possible.
	vim.pack.add({
		{ src = gh("jpalardy/vim-slime"), version = "507107dd24c9b85721fa589462fd5068e0f70266" },
	})
	vim.cmd('let g:slime_target = "neovim"')

	-- vim-fugitive is the best git-porcelain ever
	vim.pack.add({
		{ src = gh("tpope/vim-fugitive"), version = "96c1009fcf8ce60161cc938d149dd5a66d570756" }, -- v3.7
	})

	-- vim-test makes running tests in-editor easy
	vim.pack.add({
		{ src = gh("vim-test/vim-test"), version = "bb7342bd1c2c32e41092fe362a27087d2250bcf6" },
	})
	vim.cmd('let test#strategy = "neovim"')

	-- vim-sleuth automatically configures neovim to automatically detect the correct indentation style
	vim.pack.add({
		{ src = gh("tpope/vim-sleuth"), version = "be69bff86754b1aa5adcbb527d7fcd1635a84080" },
	})

	-- snippy adds very useful snippet completion
	vim.pack.add({
		{ src = gh("dcampos/nvim-snippy"), version = "93c329f7dad98565ad5db9634ced253d665c1760" },
	})
	require('snippy').setup({})

	-- Visualization for marks
	vim.pack.add({
		{ src = gh("chentoast/marks.nvim"), version = "f353e8c08c50f39e99a9ed474172df7eddd89b72" },
	})
	require('marks').setup()

	--------------------------------------------------------------------
	-- The following plugins are commented out since I didn't use     --
	-- them very much, though I may want to try them again some day.  --
	--------------------------------------------------------------------

	-- Pico-8
	--vim.pack.add({ "git@github.com:Bakudankun/PICO-8.vim.git" })

	--------------------------------------------------------------------
	-- The following LSP plugins are not versioned since they are     --
	-- core plugins for Neovim and are pretty stable between updates. --
	-- nvim-pack-lock.json still records the revision in use.         --
	--------------------------------------------------------------------

	-- lsp-config allows Neovim's native LSP to be setup
	vim.pack.add({ gh("neovim/nvim-lspconfig") })

	-- nvim-cmp adds a rich auto completedot
	vim.pack.add({
		gh("hrsh7th/nvim-cmp"),
		gh("dcampos/cmp-snippy"),
		gh("hrsh7th/cmp-buffer"),
		gh("hrsh7th/cmp-cmdline"),
		gh("hrsh7th/cmp-nvim-lsp"),
		gh("hrsh7th/cmp-path"),
		gh("hrsh7th/cmp-emoji"),
	})
end

install_plugins()

-- Include other config files after plugins are loaded and configured.
require("lsp").setup()
require("map").setup()
require("opt").setup()
require("gui").setup()

-- Use the current time for the random seed for plugins that use math.random().
math.randomseed(os.time())

local zet = require("zet")

-- Notetaking workspaces.
zet.register("Personal", os.getenv("HOME") .. "/" .. "Notes")
zet.register("Work/GlobalSign", os.getenv("HOME") .. "/" .. "GlobalSign/Notes")

-- Allow for env to set default notetaking directory
local default_zet_dir = os.getenv("DEFAULT_ZET_DIR")
if default_zet_dir ~= nil then
	zet.switch(default_zet_dir)
else
	zet.switch("Personal")
end
