 local M = {
	indices = nil,
	count = 0,
}

local function my_path()
	local debug = require("debug")
	local str = debug.getinfo(2, 'S').source:sub(2)
	return str:match('(.*' .. '/' .. ')')
end

function M.random_index_method()
	local io = require("io")
	local math = require("math")

	local path = my_path() .. "kjv.txt"

	local file = io.open(path, "r")
	if file == nil then
		print("bib: failed to open kjv.txt")
		return nil
	end

	-- get the file size
	local size = file:seek("end")
	file:seek("set")

	local n = math.random(size)

	file:seek("set", n)

	-- Read backwards until a newline is encountered
	for i = n, 0, -1 do
		file:seek("set", i)
		local rn = file:read(1)
		if rn == "\n" then
			break
		end
	end
	local verse = file:lines()()

	if verse == nil then
		print("bib:failed to find a verse")
		return nil
	end

	file:close()

	return verse
end

function M.random_line_method()
	local io = require("io")
	local math = require("math")

	local path = my_path() .. "kjv.txt"

	local file = io.open(path, "r")
	if file == nil then
		print("bib: failed to open " .. path)
		return nil
	end

	-- Compute a list of indices that mark the beginning of each verse in the bible.
	-- This is done so that each verse gets a fair chance of being displayed, rather
	-- than picking a random index in the entire text which would favor longer verses
	-- since more indices correlate to longer verses. Only the indices are stored as part
	-- of the module once computed for the first time so the entire text isn't held in memory.
	if M.indices == nil then
		M.indices = {}
		for _ in file:lines() do
			local index = file:seek("cur", 0)
			table.insert(M.indices, M.count + 1, index)
			M.count = M.count + 1
		end
	end

	-- Grab a random verse using the index list
	local n = math.random(1, M.count)
	file:seek("set", M.indices[n])
	local verse = file:lines()()

	if verse == nil then
		print("bib:failed to find a verse")
		return nil
	end

	file:close()

	return verse
end

-- verse returns a random verse from the King James Version of the Holy Bible.
function M.verse()
	return M.random_line_method()
end

function M.insert(opts)
	local verse = M.verse()
	if verse == nil then
		return
	end
	if opts and opts.above then
		vim.cmd("normal O")
	else
		vim.cmd("normal o")
	end
	vim.api.nvim_set_current_line(verse)
end

function M.print()
	print(M.verse())
end

return M
