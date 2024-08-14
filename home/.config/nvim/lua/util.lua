local M = {
	diff_branch = "master"
}

function M.yes_no(prompt, yes_fn, no_fn)
	vim.ui.input({
		prompt = prompt,
		default = "yes"
	}, function(input)
		if input == nil then return end

		if input == "y" or input == "yes" then
			yes_fn()
		elseif input == "n" or input == "no" then
			no_fn()
		end
	end)
end

function M.yank_filename()
	local path = vim.api.nvim_buf_get_name(0)
	local name = path:match("[^/\\]+$")

	vim.fn.setreg("", name)
	vim.fn.setreg("+", name)
	print("yanked file name")
end

function M.yank_filepath()
	local path = vim.api.nvim_buf_get_name(0)

	vim.fn.setreg("", path)
	vim.fn.setreg("+", path)
	print("yanked file path")
end

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

	print("yanked loc")
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
			prompt = "Set file ignore pattern: ",
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

-- set_env_var returns a function that set an environment variable value and updates an internal variable
-- with the last set value to use as the default value next time it is called.
function M.set_env_var()
	local var = ""
	local value = ""

	return function()
		local def = ""
		if var ~= "" and value ~= "" then
			def = var .. "=" .. value
		end

		vim.ui.input({
			prompt = "",
			default = def,
		}, function(input)
			if input == nil then return end

			if input ~= "" then
				var, value = string.match(input, "(.*)%=(.*)")
				print("Set " .. var.."=" .. value)
				vim.fn.setenv(var, value)
			else
			end
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
	M.yes_no("Change directory to buffer's directory? ", function()
		local dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
		vim.cmd("cd " .. dir)
		print("cd " .. dir)
	end, function()
		print("cd cancelled")
	end)
end

function M.is_git_repo(path)
	local git_dir = vim.fn.finddir(".git", path .. ";")
	return git_dir ~= ""
end

function M.git_list_changed_files()
	vim.ui.input({
		prompt = "Input branch name: ",
		default = "master"
	}, function(input)
		if input == nil then return end

		if input ~= "" then
			local changed_files = vim.fn.systemlist("git diff --name-only " .. input)
			local qflist = {}
			for _, name in ipairs(changed_files) do
				table.insert(qflist, { filename = name, lnum = 0, col = 0, text = input })
			end

			vim.cmd("copen")
			vim.fn.setqflist(qflist)
		else
			print("a branch name is expected")
		end
	end)
end

function M.git_list_changed_files_select_branch()
	local cwd = vim.fn.getcwd()
	if M.is_git_repo(cwd) == false then
		print("fatal: not a git repository (or any parent up to the mount point /)")
		return
	end

	-- Use Telescope to prompt user for input
	require("telescope.builtin").git_branches({
		prompt_title = 'Select a branch',
		cwd = cwd,
		attach_mappings = function(prompt_bufnr, map)
			-- Map Enter key to perform custom action
			map('i', '<CR>', function()
				local selection = require('telescope.actions.state').get_selected_entry()
				require("telescope.actions").close(prompt_bufnr)

				local changed_files = vim.fn.systemlist("git diff --name-only " .. selection.refname)
				local qflist = {}
				for _, name in ipairs(changed_files) do
					table.insert(qflist, { filename = name, lnum = 0, col = 0, text = selection.refname })
				end

				vim.cmd("copen")
				vim.fn.setqflist(qflist)
			end)
			return true
		end
	})
end

function M.git_list_diff_files()
	local cwd = vim.fn.getcwd()
	if M.is_git_repo(cwd) == false then
		print("fatal: not a git repository (or any parent up to the mount point /)")
		return
	end

	local branch = M.diff_branch
	if branch == nil then
		print("fatal: must select a branch to diff against first")
		return
	end

	local changed_files = vim.fn.systemlist("git diff --name-only " .. M.diff_branch)
	local qflist = {}
	for _, name in ipairs(changed_files) do
		table.insert(qflist, { filename = name, lnum = 0, col = 0, text = M.diff_branch })
	end

	vim.cmd("copen")
	vim.fn.setqflist(qflist)
end

function M.git_diff_select_branch()
	local cwd = vim.fn.getcwd()
	if M.is_git_repo(cwd) == false then
		print("fatal: not a git repository (or any parent up to the mount point /)")
		return
	end

	-- Use Telescope to prompt user for input
	require("telescope.builtin").git_branches({
		prompt_title = 'Select a branch',
		cwd = cwd,
		attach_mappings = function(prompt_bufnr, map)
			-- Map Enter key to perform custom action
			map('i', '<CR>', function()
				local selection = require('telescope.actions.state').get_selected_entry()
				require("telescope.actions").close(prompt_bufnr)

				M.diff_branch = selection.refname
			end)
			return true
		end
	})
end

function M.git_diff(cmd)
	local cwd = vim.fn.getcwd()
	if M.is_git_repo(cwd) == false then
		print("fatal: not a git repository (or any parent up to the mount point /)")
		return
	end

	local branch = M.diff_branch
	if branch == nil then
		print("fatal: must select a branch to diff against first")
		return
	end

	vim.cmd(cmd .. " " .. branch)
end

function M.close_all_but_current_buffer()
	local exclude_patterns = { '.*term:.*', '.*NvimTree.*' }

	local current_buffer = vim.api.nvim_get_current_buf()
	local buffers = vim.api.nvim_list_bufs()
	for _, buf in ipairs(buffers) do
		if buf == current_buffer then
			goto continue
		end

		local name = vim.api.nvim_buf_get_name(buf)
		local exclude = false
		for _, pattern in ipairs(exclude_patterns) do
			if name:find(pattern) then
				exclude = true
				break
			end
		end

		if exclude then
			goto continue
		end

		vim.api.nvim_buf_delete(buf, { force = true })

		::continue::
	end
end

function M.close_all_invisible_buffers()
	local buffers_in_windows = {}

	for _, winid in ipairs(vim.api.nvim_list_wins()) do
		local bufnr = vim.api.nvim_win_get_buf(winid)
		buffers_in_windows[bufnr] = true
	end

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if not buffers_in_windows[bufnr] then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end
end

function M.print_buf_name()
	local buf = vim.api.nvim_get_current_buf()
	local name = vim.api.nvim_buf_get_name(buf)
	print(name)
end

local function add_help_text(search_opts)
	local telescope_help_text = "(Tab to select, Alt-q to list)"
	if search_opts.prompt_title ~= "" then
		search_opts.prompt_title = search_opts.prompt_title .. " "
	end
	search_opts.prompt_title = search_opts.prompt_title .. telescope_help_text

	return search_opts
end

function M.find_files(search_opts)
	if search_opts == nil then
		search_opts = {}
	end

	if search_opts.prompt_title == nil then
		search_opts.prompt_title = "Find Files"
	end

	search_opts = add_help_text(search_opts)
	require("telescope.builtin").find_files(search_opts)
end

function M.live_grep(search_opts)
	if search_opts == nil then
		search_opts = {}
	end

	if search_opts.prompt_title == nil then
		search_opts.prompt_title = "Live Grep"
	end

	search_opts = add_help_text(search_opts)
	require("telescope.builtin").live_grep(search_opts)
end

function M.copilot_status()
	if vim.b.copilot_enabled == true then
		print("copilot=true")
	elseif vim.b.copilot_enabled == false then
		print("copilot=false")
	else
		print("copilot=auto")
	end
end

function M.copilot_toggle()
	if vim.b.copilot_enabled ~= true then
		vim.b.copilot_enabled = true
	else
		vim.b.copilot_enabled = false
	end

	M.copilot_status()
end

return M
