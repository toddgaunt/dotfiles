local M = {}

-- current_path holds the current working directory for the zettelkasten note map.
M.current_path = ""

-- spaces associates short names with paths on the filesystem that lead to zettelkasten note mappaths on the filesystem that lead to zettelkasten note maps
M.spaces = {}
M.spaces_len = 0

local subspaces = { "Zettelkasten", "Diary", "Collections", "Reference"}

-- select_initial_space is called at the start of most exported functions of this module to prompt the user to pick a collection if one wasn't selected already.
local function select_initial_space()
	if M.current_path == "" then
		if M.spaces_len == 0 then
			print("a space must be registered to create notes")
			return
		elseif M.spaces_len == 1 then
			M.current_path = next(M.spaces)
		else
			M.select()
			-- If the user fails to select a space, just return without creating a
			-- note since they likely just wanted to cancel the action.
			if M.current_path == "" then
				return
			end
		end
	end
end

-- register associates a name with a fullpath to a space.
function M.register(name, fullpath)
	if M.spaces[name] == nil then
		M.spaces_len = M.spaces_len + 1
	end
	M.spaces[name] = fullpath
end

-- switch changes the space.
function M.switch(name)
	if M.spaces[name] ~= nil then
		M.current_path = M.spaces[name]
	else
		print('space "' .. name .. '" must first be registered with zet.register("' .. name .. '")')
	end
end

-- select prompts the user to select a space.
function M.select()
	local names = {}
	local n = 0
	for k, _ in pairs(M.spaces) do
		n = n + 1
		table.insert(names, n, k)
	end

	if n == 0 then
		print("no space available")
		return
	end

	table.sort(names)

	vim.ui.select(names, {
		prompt = "Select zettelkasten space for this session",
	}, function(choice)
		if choice == nil then return end

		if choice ~= "" then
			M.switch(choice)
		end
	end)
end

-- link finds a note using Telescope in M.current_path and insert's its name as a markdown link.
function M.link()
	select_initial_space()

	local opts = {
		prompt_title = "Link Zettelkasten", -- Title for the picker
		cwd = M.current_path .. "/Zettelkasten", -- Set path to current space
		initial_mode = "insert",
		selection_strategy = "reset",
		attach_mappings = function(_, map)
			map("i", "<CR>", function(prompt_bufnr)
				local entry = require("telescope.actions.state").get_selected_entry()
				if entry == nil then
					return
				end

				local result = entry[1]
				require("telescope.actions").close(prompt_bufnr)

				local filename = string.gsub(result, '([^%.]*)%.md.*', '%1', 1)
				local filepath = "Zettelkasten/" .. string.gsub(result, '([^%.]*%.md).*', '%1', 1)

				-- Insert filename in current cursor position
				vim.cmd('normal i' .. '[' .. filename .. ']' .. '(' .. filepath .. ')')
				vim.cmd('stopinsert')
			end)

			return true
		end,
	}

	-- Pass opts to find_files
	require("telescope.builtin").live_grep(opts)
end

-- find uses Telescope to find a note based on its filename inside M.current_path.
function M.find(subpath)
	select_initial_space()

	local cwd = M.current_path
	if subpath ~= nil then
		cwd = cwd .. subpath
	end

	local opts = {
		prompt_title = "Find Zettelkasten",                             -- Title for the picker
		shorten_path = false,                                           -- Display full paths, short paths are ugly
		cwd = cwd,
		file_ignore_patterns = { "TODO.md", ".git", ".jpg", ".png", "tags" }, -- Folder/files to be ignored
		initial_mode = "insert",
		selection_strategy = "reset",
	}
	-- Pass opts to find_files
	require("telescope.builtin").find_files(opts)
end

-- search uses Telescope to find a note by pattern-matching its contents inside M.current_path.
function M.search(subpath)
	select_initial_space()

	local cwd = M.current_path
	if subpath ~= nil then
		cwd = cwd .. subpath
	end

	local opts = {
		prompt_title = "Search Zettelkasten Contents", -- Title for the picker
		cwd = cwd,
		initial_mode = "insert",
		selection_strategy = "reset",
	}

	-- Pass opts to find_files
	require("telescope.builtin").live_grep(opts)
end

function M.find_select()
	vim.ui.select(subspaces, {
		prompt = "Select subspace",
	}, function(choice)
		if choice == nil then return end

		M.find("/" .. choice)
	end)
end

function M.search_select()
	vim.ui.select(subspaces, {
		prompt = "Select subspace",
	}, function(choice)
		if choice == nil then return end

		M.search("/" .. choice)
	end)
end

-- open prompts the user for a name of a file and opens the file inside M.current_path.
function M.open()
	select_initial_space()

	vim.ui.input({
		prompt = "Input the name of the note: ",
	}, function(input)
		if input == nil then return end

		vim.cmd("e " .. M.current_path .. "/Collections/" .. input .. ".md")
	end)
end

-- new creates a new file in M.current_path with an automatic unique filename.
function M.new()
	select_initial_space()

	local file_name = os.date("%y%m%d%H%M%S.md")
	local formatted_date = os.date("# %Y.%m.%d %a")
	vim.cmd("execute 'e " .. M.current_path .. "/Zettelkasten/" .. file_name .. "'")
	vim.api.nvim_buf_set_lines(0, 0, 0, false, { formatted_date })
end

local function buf_is_empty(buf)
	local n = vim.api.nvim_buf_line_count(buf)
	if n == 0 then
		return true
	elseif n == 1 then
		return vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
	else
		return false
	end
end

local function new_diary(file_name_format, title_format)
	local file_name = os.date("Diary/" .. file_name_format)
	local formatted_date = os.date(title_format)
	local file_path = M.current_path .. "/" .. file_name

	vim.cmd("execute 'e " .. file_path .. "'")

	if buf_is_empty(vim.api.nvim_get_current_buf()) then
		vim.api.nvim_buf_set_lines(0, 0, 1, false, { formatted_date })
	end
end

-- daily creates a new diary file for the current day in M.current_path/Diary with an automatic unique filename.
function M.daily()
	return new_diary("%Y-%m-%d.md", "# Daily <%Y.%m.%d %a>")
end

-- weekly creates a new diary file for the current week in M.current_path/Diary with an automatic unique filename.
function M.weekly()
	return new_diary("%Y-w%V.md", "# Weekly <%Y %V/52>")
end

-- monthly creates a new diary file for the current month in M.current_path/Diary
function M.monthly()
	return new_diary("%Y-%m.md", "# Monthly <%Y.%m>")
end

-- yearly creates a new diary file for the current year in M.current_path/Diary
function M.yearly()
	return new_diary("%Y.md", "# Yearly <%Y>")
end

local function get_filepath()
	local path = vim.api.nvim_buf_get_name(0)
	local name = path:match("[^/\\]+$")
	local dir = path:match("(.*/)[^/\\]+$")
	return dir, name
end

local function filter_files(files, pattern)
	local filtered_files = {}
	local n = 1
	for _, f in ipairs(files) do
		if f:match(pattern) then
			filtered_files[n]= f
			n = n + 1
		end
	end
	return filtered_files
end

local function filter_files_by_filename(a, filename)
	local year, month, day

	year, month, day = filename:match("(%d%d%d%d)-(%d%d)-(%d%d).md")
	if year ~= nil and month ~= nil and day ~= nil then
		return filter_files(a, "(%d%d%d%d)-(%d%d)-(%d%d).md")
	end

	year, month = filename:match("(%d%d%d%d)-(%d%d).md")
	if year ~= nil and month ~= nil then
		return filter_files(a, "(%d%d%d%d)-(%d%d).md")
	end

	year = filename:match("(%d%d%d%d).md")
	if year ~= nil then
		return filter_files(a, "(%d%d%d%d).md")
	end

	return nil
end

-- prev opens the previous entry of the same type as the current buffer.
-- If the current buffer is not a zettelkasten entry an error is displayed.
function M.prev()
	local dir, name = get_filepath()
	local dirfiles = require("plenary.scandir").scan_dir(M.current_path .. "/Diary")
	local filtered_files = filter_files_by_filename(dirfiles, name)
	if filtered_files == nil then
		print("can't get previous entry")
		return
	end

	for i,f in ipairs(filtered_files) do
		if f == (dir .. name) then
			if i > 1 then
				vim.cmd("execute 'e " .. filtered_files[i + -1] .. "'")
				return
			else
				print("can't get previous entry")
				return
			end
			break
		end
	end

	print("current file is not a note")
end

-- next opens the next entry of the same type as the current buffer.
-- If the current buffer is not a zettelkasten entry an error is displayed.
function M.next()
	local dir, name = get_filepath()
	local dirfiles = require("plenary.scandir").scan_dir(M.current_path .. "/Diary")
	local filtered_files = filter_files_by_filename(dirfiles, name)
	if filtered_files == nil then
		print("can't get next entry")
		return
	end

	for i,f in ipairs(filtered_files) do
		if f == (dir .. name) then
			if i < #filtered_files then
				vim.cmd("execute 'e " .. filtered_files[i + 1] .. "'")
				return
			else
				print("can't get next entry")
				return
			end
			break
		end
	end

	print("current file is not a note")
end

function M.cd_to_current_collection()
	vim.cmd("cd " .. M.current_path)
end

function M.todo()
	select_initial_space()
	vim.cmd("e " .. M.current_path .. "/TODO.md")
end

return M
