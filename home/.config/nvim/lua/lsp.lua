--
-- Autocomplete Config
--

local cmp = require("cmp")
local lspconfig = require("lspconfig")
local util = require("lspconfig/util")

cmp.setup {
	-- Don't autoselect an item or automatically insert it.
	preselect = 'none',
	completion = {
		completeopt = 'menu,menuone,noselect',
		cmp.config.compare.length
	},

	-- Sort alphabetically, then by length (shortest first!).
	sorting = {
		--comparators = {
		-- These two are important!
		-- cmp.config.compare.sort_text,
		-- cmp.config.compare.length,
		-- I don't really know about these ones.
		-- cmp.config.compare.offset,
		-- cmp.config.compare.exact,
		-- cmp.config.compare.score,
		-- cmp.config.compare.recently_used,
		-- cmp.config.compare.locality,
		-- cmp.config.compare.kind,
		-- cmp.config.compare.order,
		--},
	},

	snippet = {
		-- REQUIRED - you must specify a snippet engine.
		expand = function(args)
			require('snippy').expand_snippet(args.body) -- For `snippy` users.
		end,
	},

	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},

	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-e>'] = cmp.mapping.abort(),
		['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),

	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'snippy' },
	}, {
		{ name = 'buffer' },
		{ name = 'emoji' },
	}),
}

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
	sources = cmp.config.sources({
		{ name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
	}, {
		{ name = 'buffer' },
	})
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	})
})

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

--
-- Neovim LSP Config
--

-- Mappings.
local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", opts)
vim.api.nvim_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-]>", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
end

-- Generic LSP Configuration:
-- Use a loop to conveniently call "setup" on multiple servers that don't
-- require custom configuration and to map buffer local keybindings when the
-- language server attaches
local servers = { "bashls", "pyright", "tsserver" }
for _, lsp in pairs(servers) do
	lspconfig[lsp].setup {
		capabilities = capabilities,
		on_attach = on_attach,
	}
end

--
-- Lua LSP configuration
--
lspconfig.lua_ls.setup {
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
			},
			diagnostics = {
				-- Recognize the neovim provided 'vim' global variable.
				globals = { "vim" },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = {
				-- Do not send telemetry data containing a randomized but unique identifier
				enable = false,
			},
		}
	}
}

function LuaFormat()
	vim.lsp.buf.format({ async = true })
end

vim.cmd('autocmd BufWritePre *.lua lua LuaFormat()')

--
-- Golang LSP configuration
--
lspconfig.gopls.setup {
	cmd = { "gopls", "serve" },
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "go", "gomod" },
	root_dir = util.root_pattern("go.work", "go.mod", ".git"),
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
				fillstruct = true,
				--shadow = true,
			},
			staticcheck = true,
		},
	},
	init_options = {
		usePlaceholders = true,
	}
}

function GoFumport(wait_ms)
	local params = vim.lsp.util.make_range_params()
	params.context = { only = { "source.organizeImports" } }
	local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
	for cid, res in pairs(result or {}) do
		for _, r in pairs(res.result or {}) do
			if r.edit then
				local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
				vim.lsp.util.apply_workspace_edit(r.edit, enc)
			else
				vim.lsp.buf.execute_command(r.command)
			end
		end
	end
	vim.lsp.buf.format({ async = true })
end

vim.cmd('autocmd BufWritePre *.go lua GoFumport(1000)')

--
-- Python LSP configuration
--
vim.cmd('autocmd BufWritePost *.py !black %')
