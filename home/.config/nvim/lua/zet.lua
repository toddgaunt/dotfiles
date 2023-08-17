local M = {}

-- current_path holds the current working directory for the zettelkasten notemap.
M.current_path = ""

-- collections associates short names with paths on the filesystem that lead to zettelkasten note mappaths on the filesystem that lead to zettelkasten note maps
M.collections = {}
M.collections_len = 0

-- select_initial_collection is called at the start of most exported functions of this module to prompt the user to pick a collection if one wasn't selected already.
local function select_initial_collection()
	if M.current_path == "" then
		if M.collections_len == 0 then
			print("a collection must be registered to create notes")
			return
		elseif M.collections_len == 1 then
			M.current_path = next(M.collections)
		else
			M.select()
			-- If the user fails to select a collection, just return without creating a
			-- note since they likely just wanted to cancel the action.
			if M.current_path == "" then
				return
			end
		end
	end
end

-- register associates a name with a collection path.
function M.register(name, path)
	if M.collections[name] == nil then
		M.collections_len = M.collections_len + 1
	end
	M.collections[name] = path
end

-- switch changes the collection.
function M.switch(name)
	if M.collections[name] ~= nil then
		M.current_path = M.collections[name]
	else
		print('collection "' .. name .. '" must first be registered with zet.register("' .. name .. '")')
	end
end

-- select prompts the user to select a collection.
function M.select()
	local names = {}
	local n = 0
	for k, _ in pairs(M.collections) do
		n = n + 1
		table.insert(names, n, k)
	end

	if n == 0 then
		print("no collections available")
		return
	end

	table.sort(names)

	vim.ui.select(names, {
		prompt = "Select zettelkasten collection for this session",
	}, function(choice)
		if choice == nil then return end

		if choice ~= "" then
			M.switch(choice)
		end
	end)
end

-- link finds a note using Telescope in M.current_path and insert's its name as a markdown link.
function M.link()
	select_initial_collection()

	local opts = {
		prompt_title = "Link Zettelkasten", -- Title for the picker
		cwd = M.current_path,         -- Set path to current collection
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
				local filepath = string.gsub(result, '([^%.]*%.md).*', '%1', 1)

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
function M.find()
	select_initial_collection()

	local opts = {
		prompt_title = "Find Zettelkasten",                             -- Title for the picker
		shorten_path = false,                                           -- Display full paths, short paths are ugly
		cwd = M.current_path,                                           -- Set path to current collection
		file_ignore_patterns = { "TODO.md", ".git", ".jpg", ".png", "tags" }, -- Folder/files to be ignored
		initial_mode = "insert",
		selection_strategy = "reset",
	}
	-- Pass opts to find_files
	require("telescope.builtin").find_files(opts)
end

-- search uses Telescope to find a note by pattern-matching its contents inside M.current_path.
function M.search()
	select_initial_collection()

	local opts = {
		prompt_title = "Search Zettelkasten Contents", -- Title for the picker
		cwd = M.current_path,                    -- Set path to current collection
		initial_mode = "insert",
		selection_strategy = "reset",
	}

	-- Pass opts to find_files
	require("telescope.builtin").live_grep(opts)
end

-- open prompts the user for a name of a file and opens the file inside M.current_path.
function M.open()
	select_initial_collection()

	vim.ui.input({
		prompt = "Input the name of the note: ",
	}, function(input)
		if input == nil then return end

		vim.cmd("e " .. M.current_path .. "/" .. input .. ".md")
	end)
end

-- new creates a new file in M.current_path with an automatic unique filename. If M.current_path isn't set, there are three possibilities:
-- 1. If no collections are registered a message is displayed to the user and the function returns
-- 2. If one collection is registered then it is used by default.
-- 3. If there is more than one registered collection the user is prompted to select one.
function M.new()
	select_initial_collection()

	vim.cmd("execute 'e " .. M.current_path .. "/'.strftime(\"%y%m%d%H%M%S\").'.md'")
end

return M
