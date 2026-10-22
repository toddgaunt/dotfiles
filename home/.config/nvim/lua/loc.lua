local M = {}

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

-- parse_loc splits a location in the form path[:row[:col]] into its parts.
-- The row and col segments may also be ranges (e.g. path:10-20:5-8), in which
-- case only the start of each range is used. Returns nil and an error message
-- if a segment is malformed.
local function parse_loc(loc)
	-- Peel numeric segments off the end so the path itself may contain ':'.
	local path = loc
	local segments = {}
	while true do
		local rest, seg = string.match(path, "^(.+):([%d%.%-]+)$")
		if rest == nil then break end
		if not string.match(seg, "^%d+$") and not string.match(seg, "^%d+[%.%-]%d+$") then
			return nil, "Invalid location: " .. loc
		end
		table.insert(segments, 1, seg)
		path = rest
	end

	local row = tonumber(string.match(segments[1] or "", "^%d+"))
	local col = tonumber(string.match(segments[2] or "", "^%d+"))
	return path, row, col
end

-- resolve_loc_path returns the absolute path of an existing file, looking
-- relative to the cwd and then to the current buffer's directory.
local function resolve_loc_path(path)
	path = vim.fs.normalize(path)
	local candidates = { path }
	if not vim.startswith(path, "/") then
		table.insert(candidates, vim.fs.joinpath(vim.fn.expand("%:p:h"), path))
	end
	for _, candidate in ipairs(candidates) do
		if vim.fn.filereadable(candidate) == 1 then
			return vim.fn.fnamemodify(candidate, ":p")
		end
	end
end

-- loc_line returns the line count of the file at path and the text of line
-- row, preferring a loaded buffer so unsaved changes are taken into account.
local function loc_line(path, row)
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_name(bufnr) == path then
			local count = vim.api.nvim_buf_line_count(bufnr)
			return count, vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
		end
	end
	local lines = vim.fn.readfile(path)
	return #lines, lines[row]
end

-- check_loc returns the absolute path, row and col of loc, or nil and an
-- error message if loc isn't a position within an existing file.
local function check_loc(loc)
	local path, row, col = parse_loc(loc)
	if path == nil then return nil, row end

	local resolved = resolve_loc_path(path)
	if resolved == nil then
		return nil, "No such file: " .. path
	end

	if row ~= nil then
		local count, line = loc_line(resolved, row)
		if row < 1 or row > count then
			local clamped = math.max(1, math.min(row, count))
			vim.notify(string.format("%s clamped to line %d", path, clamped))
			row = clamped
			_, line = loc_line(resolved, row)
		end
		line = line or ""
		if col ~= nil and (col < 1 or col > math.max(#line, 1)) then
			local clamped = math.max(1, math.min(col, #line))
			vim.notify(string.format("%s clamped to column %d", path, clamped))
			col = clamped
		end
	end
	return resolved, row, col
end

local function open_loc(path, row, col)
	-- Re-editing the current file would fail if the buffer is modified.
	if path ~= vim.api.nvim_buf_get_name(0) then
		vim.cmd.edit(vim.fn.fnameescape(path))
	end

	if row ~= nil then
		vim.cmd("normal! m'")
		vim.api.nvim_win_set_cursor(0, { row, (col or 1) - 1 })
	end
end

-- goto_loc opens loc, or reports why it can't be opened.
local function goto_loc(loc)
	local path, row, col = check_loc(loc)
	if path == nil then
		vim.notify(row, vim.log.levels.WARN)
		return
	end
	open_loc(path, row, col)
end

-- loc_under_cursor returns the text under the cursor delimited by whitespace,
-- quotes and brackets, without trailing punctuation. Returns nil unless the
-- cursor is on a character of that text.
local function loc_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local cursor = vim.api.nvim_win_get_cursor(0)[2] + 1
	local init = 1
	while true do
		local s, e = string.find(line, "[^%s\"'`()%[%]<>{}|,;]+", init)
		if s == nil or s > cursor then return nil end
		if e >= cursor then
			local text = string.gsub(string.sub(line, s, e), "[%.:!?]+$", "")
			if s + #text - 1 < cursor then return nil end
			return text
		end
		init = e + 1
	end
end

-- goto_cursor_loc opens the location under the cursor.
function M.goto_cursor_loc()
	local loc = loc_under_cursor()
	if loc == nil then
		vim.notify("No location under cursor", vim.log.levels.WARN)
		return
	end
	goto_loc(loc)
end

-- goto_selected_loc opens the selected location.
function M.goto_selected_loc()
	local util = require("util")
	local loc = vim.trim(util.get_visual_selection())
	if loc == "" then
		vim.notify("No location selected", vim.log.levels.WARN)
		return
	end
	goto_loc(loc)
end

return M
