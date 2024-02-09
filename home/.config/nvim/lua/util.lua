local M = {}

function M.yank_filename()
	vim.cmd('let @" = expand("%:t")')
	print("yanked file name")
end

function M.yank_filepath()
	vim.cmd('let @" = expand("%")')
	print("yanked file path")
end

--function M.yank_fullpath()
--vim.cmd('let @" = expand("%:p")')
--print("yanked full path")
--end

function M.workspace_rename()
	local ws = require("workspaces")
	vim.ui.input({
		prompt = "Rename workspace: ",
		default = ws.name() .. " " .. ws.name()
	}, function(input)
		if input == nil then return end

		if input ~= "" then
			vim.cmd("WorkspacesRename " .. input)
		end
	end)
end

function M.workspace_select()
	local ws = require("workspaces")

	local names = {}
	for _, v in pairs(ws.get()) do
		table.insert(names, v.name)
	end

	vim.ui.select(names, {
		prompt = "Select workspace:",
	}, function(choice)
		if choice == nil then return end

		ws.open(choice)
		if choice == "spaces" then
			vim.o.expandtab = true
		elseif choice == "tabs" then
			vim.o.expandtab = false
		else
			vim.o.expandtab = false
		end
	end)
end

function M.get_loc()
	local path = vim.api.nvim_buf_get_name(0)
	local loc = vim.api.nvim_win_get_cursor(0)

	-- Note: this only works as expected when the file you are copying is inside the cwd.
	--local relpath = path.sub(path, #cwd + 1) .. ":" ..  tostring(loc[1])

	-- Instead this is used since only fullpath yanking behaves as expected.
	local pathloc = path .. ":" .. tostring(loc[1])

	vim.fn.setreg("", pathloc)
	vim.fn.setreg("+", pathloc)
end

function M.get_visual_selection()
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

-- The function to set the ignore patterns can be bound
-- to allow this to be changed by user input. A default
-- table of ignore patterns may be passed in as the argument.
function M.set_file_ignore_patterns(file_ignore_patterns)
	require("telescope").setup({
		defaults = {
			file_ignore_patterns = file_ignore_patterns,
		},
	})

	return function()
		vim.ui.input({
			prompt = "Set find ignore pattern: ",
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

-- [[UI functions]] --
function M.select_indentation()
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

function M.select_tab_length()
	vim.ui.select({ 1, 2, 3, 4, 5, 6, 7, 8 }, {
		prompt = "Select tab length",
	}, function(choice)
		if choice == nil then return end

		vim.o.tabstop = choice
	end)
end

function M.toggle_spellcheck()
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

function M.new_toggle(init, fn)
	local toggle = init
	return function()
		toggle = not toggle
		fn(toggle)
	end
end

function M.toggle_autocomplete(value)
	return M.new_toggle(true, function()
		print("autocomplete=" .. tostring(value))
		require('cmp').setup.buffer { enabled = value }
	end)
end

-- bd returns a function that deletes the current buffer. If force is true, it
-- is deleted even if there is unsaved content.
function M.bd(force)
	return function()
		require("mini.bufremove").delete(0, force)
	end
end

-- Custom mapping to allow for telescope search inside of directories relative to the current buffer.
function M.find_buffer_relative_pattern()
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

function M.cd_to_buf()
	vim.cmd("cd " .. vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
end

return M
