local packer = require("packer")
packer.startup(function(use)
	-- Package manager for installing all other packages
	use "wbthomason/packer.nvim"

	-- Mason makes installing language server tools dead-easy
	use {
		"williamboman/mason.nvim",
		config = function()
			require('mason').setup()
		end,
	}

	-- which-key is the best keybinding plugin ever
	use {
		"folke/which-key.nvim",
		config = function()
			vim.opt.timeout = true
			vim.opt.timeoutlen = 0
			require('which-key').setup {
				sort_by_description = true,
			}
		end
	}

	-- vim-lastplace remembers my last cursor position in files
	use "farmergreg/vim-lastplace"

	-- luatab provides a better tab bar
	use {
		"alvarosevilla95/luatab.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("luatab").setup()
		end
	}

	-- gitsigns adds git status symbols in the gutter
	use {
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add          = { hl = 'GitSignsAdd', text = '+│', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
					change       = {
						hl = 'GitSignsChange',
						text = '~│',
						numhl = 'GitSignsChangeNr',
						linehl = 'GitSignsChangeLn'
					},
					delete       = {
						hl = 'GitSignsDelete',
						text = '-│',
						numhl = 'GitSignsDeleteNr',
						linehl = 'GitSignsDeleteLn'
					},
					topdelete    = {
						hl = 'GitSignsDelete',
						text = '-│',
						numhl = 'GitSignsDeleteNr',
						linehl = 'GitSignsDeleteLn'
					},
					changedelete = {
						hl = 'GitSignsChange',
						text = '-│',
						numhl = 'GitSignsChangeNr',
						linehl = 'GitSignsChangeLn'
					},
					untracked    = { hl = 'GitSignsAdd', text = '+┆', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
				},
			})
		end,
	}

	-- mini.bufremove maintains window layout when deleting a buffer
	use {
		"echasnovski/mini.bufremove",
		config = function()
			require("mini.bufremove").setup({})
		end
	}

	-- treesitter provides better syntax highlighting based on parsing the code instead of regex
	use {
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"bash",
					"c",
					"go",
					"help",
					"html",
					"javascript",
					"json",
					"latex",
					"lua",
					"markdown",
					"markdown_inline",
					"python",
					"python",
					"query",
					"regex",
					"tsx",
					"typescript",
					"vim",
					"yaml",
				},
				sync_install = false,
				auto_install = true,
				indent = {
					enable = false
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
				view = {
					preserve_window_proportions = true,
					signcolumn = "no",
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
		tag = "0.1.3",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-fzf-native.nvim",
		},
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<tab>"] = require("telescope.actions.layout").toggle_preview,
							["<S-tab>"] = require("telescope.actions.layout").cycle_layout_next,
						}
					},
					wrap_results = true,
					path_display = {
						--tail = true
						--shorten = 2,
						--smart = true,
						--truncate = 3,
					},
					dynamic_preview_title = true,
					preview = {
						hide_on_startup = true,
					}
				},
			})
		end
	}

	-- session management makes switching projects easier
	use {
		"natecraddock/sessions.nvim",
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
		config = function()
			require("workspaces").setup({
				hooks = {
					open_pre = function()
						-- If recording, save current session state and stop recording
						require("sessions").stop_autosave({save=true})

						-- delete all buffers (does not save changes)
						vim.cmd("silent %bdelete!")
					end,

					open = function()
						require("sessions").load(nil, {})
						require("sessions").save(nil, {})
						vim.cmd("NvimTreeFindFile")
					end,
				}
			})
			require("telescope").load_extension("workspaces")
		end
	}

	-- vim-slime makes REPL development possible.
	use {
		"jpalardy/vim-slime",
		config = function()
			vim.cmd('let g:slime_target = "neovim"')
		end

	}

	-- vim-delve gives access to the Go debugger
	use "sebdah/vim-delve"

	-- vim-fugitive is the best git-porcelain ever
	use "tpope/vim-fugitive"

	-- vim-test makes running tests in-editor easy
	use {
		"vim-test/vim-test",
		config = function()
			vim.cmd('let test#strategy = "neovim"')
		end
	}

	-- vim-sleuth automatically configures neovim to automatically detect the correct indentation style
	use "tpope/vim-sleuth"

	-- snippy adds very useful snippet completion
	use {
		"dcampos/nvim-snippy",
		config = function()
			require('snippy').setup({})
		end,
	}

	-- lsp-config allows Neovim's native LSP to be setup
	use "neovim/nvim-lspconfig"

	-- nvim-cmp adds a rich auto complete
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

	-- barbecue adds a path to the top of each window leading to the current code object the cursor resides in
	use {
		"utilyre/barbecue.nvim",
		requires = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("barbecue").setup()
		end,
	}

	-- copilot integrates Github Copilot with the editor for AI-driven code suggestions
	use {
		"github/copilot.vim",
		config = function()
			vim.keymap.set('i', '<C-f>', 'copilot#Accept("\\<CR>")', {
				expr = true,
				replace_keycodes = false
			})
			vim.g.copilot_no_tab_map = false
		end,
	}
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
