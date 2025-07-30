local packer = require("packer")
packer.startup(function(use)
	-- Package manager for installing all other packages
	use {
		"wbthomason/packer.nvim",
		commit = "ea0cc3c59f67c440c5ff0bbe4fb9420f4350b9a3",
	}

	use {
		"williamboman/mason.nvim",
		tag = "v2.0.0",
		commit = "7f265cd6ae56cecdd0aa50c8c73fc593b0604801",
		config = function()
			require("mason").setup()
		end
	}

	-- which-key is the best keybinding plugin ever
	use {
		"folke/which-key.nvim",
		tag = "v2.1.0",
		commit = "0539da005b98b02cf730c1d9da82b8e8edb1c2d2",
		config = function()
			vim.opt.timeout = true
			vim.opt.timeoutlen = 0
			require('which-key').setup {
				sort_by_description = true,
			}
		end
	}

	-- vim-lastplace remembers my last cursor position in files
	use {
		"farmergreg/vim-lastplace",
		tag = "v4.4.0",
		commit = "17b69463aa384b990a8d45e4fd241f446ac0be1e",
	}

	-- luatab provides a better tab bar
	use {
		"alvarosevilla95/luatab.nvim",
		commit = "7ac54b014b542f02a73b62fcae65db7a2382a378",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("luatab").setup()
		end
	}

	-- gitsigns adds git status symbols in the gutter
	use {
		"lewis6991/gitsigns.nvim",
		tag="v1.0.2",
		commit="7010000889bfb6c26065e0b0f7f1e6aa9163edd9",
		config = function()
			require("gitsigns").setup()
		end,
	}

	-- mini.bufremove maintains window layout when deleting a buffer
	use {
		"echasnovski/mini.bufremove",
		tag = "v0.16.0",
		commit = "66019ecebdc5bc0759e04747586994e2e3f98416",
		config = function()
			require("mini.bufremove").setup()
		end
	}

	-- treesitter provides better syntax highlighting based on parsing the code instead of regex
	-- No tag or commit is to allow for automatic updates since this plugin has frequent fixes.
	use {
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"c",
					"lua",
					"vim",
					"bash",
					"go",
					"html",
					"javascript",
					"json",
					"latex",
					"markdown",
					"markdown_inline",
					"python",
					"query",
					"regex",
					"tsx",
					"typescript",
					"yaml",
				},
				sync_install = false,
				auto_install = true,
				indent = {
					enable = true
				},
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				modules = {},
				ignore_install = {},
			})
		end,
	}

	-- nvim-tree provides a file-explorer tree with icon support
	use {
		"nvim-tree/nvim-tree.lua",
		tag = "v1.12.0",
		commit = "be5b788f2dc1522c73fb7afad9092331c8aebe80",
		requires = {
			"nvim-tree/nvim-web-devicons"
		},
		config = function()
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
								filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame", },
								buftype  = { "help", "terminal", "minimap" },
							},
						},
					},
				},
			})
		end
	}

	-- telescope is a very powerful fuzzy finder with a great UI
	use {
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		commit = "a0bbec21143c7bc5f8bb02e0005fa0b982edc026",
		requires = {
			{
				"nvim-lua/plenary.nvim",
				commit="08e301982b9a057110ede7a735dd1b5285eb341f",
			},
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				commit="9ef21b2e6bb6ebeaf349a0781745549bbb870d27",
			},
		},
		config = function()
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
		end
	}

	-- session management makes switching projects easier
	use {
		"natecraddock/sessions.nvim",
		commit = "f13158483e0b6255c6dfe473145ce4ee3495d844",
		config = function()
			require("sessions").setup({
				events = { "VimLeavePre" },
				session_filepath = vim.fn.stdpath("data") .. "/sessions",
				absolute = true,
			})
		end
	}

	-- workspaces allows for easily changing between projects
	use {
		"natecraddock/workspaces.nvim",
		commit = "55a1eb6f5b72e07ee8333898254e113e927180ca",
		config = function()
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
		end
	}

	-- vim-slime makes REPL development possible.
	use {
		"jpalardy/vim-slime",
		commit = "507107dd24c9b85721fa589462fd5068e0f70266",
		config = function()
			vim.cmd('let g:slime_target = "neovim"')
		end

	}

	-- vim-delve gives access to the Go debugger
	use {
		"sebdah/vim-delve",
		commit = "41d6ad294fb6dd5090f5f938318fc4ed73b6e1ea",
	}

	-- vim-fugitive is the best git-porcelain ever
	use {
		"tpope/vim-fugitive",
		tag = "v3.7",
		commit = "96c1009fcf8ce60161cc938d149dd5a66d570756",
	}

	-- vim-test makes running tests in-editor easy
	use {
		"vim-test/vim-test",
		commit = "bb7342bd1c2c32e41092fe362a27087d2250bcf6",
		config = function()
			vim.cmd('let test#strategy = "neovim"')
		end
	}

	-- vim-sleuth automatically configures neovim to automatically detect the correct indentation style
	use {
		"tpope/vim-sleuth",
		commit = "be69bff86754b1aa5adcbb527d7fcd1635a84080",
	}

	-- snippy adds very useful snippet completion
	use {
		"dcampos/nvim-snippy",
		commit = "93c329f7dad98565ad5db9634ced253d665c1760",
		config = function()
			require('snippy').setup({})
		end,
	}

	-- vim-surround to edit your surroundings
	use {
		"tpope/vim-surround",
		commit = "3d188ed2113431cf8dac77be61b842acb64433d9",
	}

	-- Pico-8
	--use "git@github.com:Bakudankun/PICO-8.vim.git"

	-- The following LSP plugins are not versioned since they are
	-- core plugins for Neovim and are pretty stable between updates.

	-- lsp-config allows Neovim's native LSP to be setup
	use "neovim/nvim-lspconfig"

	-- nvim-cmp adds a rich auto completedot
	use {
		"hrsh7th/nvim-cmp",
		requires = {
			"dcampos/cmp-snippy",
			"dcampos/nvim-snippy",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-emoji",
			"neovim/nvim-lspconfig",
		},
	}

	-- copilot integrates Github Copilot with the editor for AI-driven code suggestions
--	use {
--		"github/copilot.vim",
--		config = function()
--			vim.keymap.set('i', '<C-f>', 'copilot#Accept("\\<CR>")', {
--				expr = true,
--				replace_keycodes = false
--			})
--			vim.g.copilot_no_tab_map = true
--			vim.g.copilot_enabled = true
--		end,
--	}
end)

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
