local M = {}

local taskPattern = "(%s*)%- %[.]"
--local topTaskPattern = taskPattern .. "[^:]*:"
local topTaskPattern = taskPattern .. ".-:\n"

-- create_deadline inserts a deadline on the current task
function M.create_deadline()
	vim.ui.input({
		prompt = "Input a deadline: "
	}, function(input)
		if input == nil then
			return
		end

		local line = vim.api.nvim_get_current_line()
		local sub, count = string.gsub(line, "(%s*)%- %[[%s.]]%s*", "%1- [!] -> " .. input .. " <- ", 1)
		if count == 1 then
			vim.api.nvim_set_current_line(sub)
		else
			vim.api.nvim_echo({ { "failed to match task pattern on current line" } }, true, {})
		end
	end)
end

-- create_task inserts a task intelligently
function M.create_task(opts)
	local line = vim.api.nvim_get_current_line()
	-- case1 is for any task that ends with a ':' character.
	-- This indicates that any indented following subtasks.
	--
	-- Newlines are appended to line to ensure that the patterns
	-- can match until the end of the line.
	local _, _, case1 = string.find(line .. "\n", topTaskPattern)
	local _, _, case2 = string.find(line .. "\n", taskPattern)
	local task = vim.api.nvim_eval('strftime("- [ ] %m.%d")')

	if case1 ~= nil then
		task = case1 .. "\t" .. task
	elseif case2 ~= nil then
		task = case2 .. task
	end

	if opts and opts.above then
		vim.cmd("normal O")
	else
		vim.cmd("normal o")
	end
	vim.api.nvim_set_current_line(task)
end

-- cancel_task inserts a deadline on the current task.
function M.cancel_task()
	local line = vim.api.nvim_get_current_line()
	local sub, count = string.gsub(line, taskPattern .. "%s*~?([^~]+)~?%s*", "%1- [~] ~%2~", 1)
	if count == 1 then
		vim.api.nvim_set_current_line(sub)
	end
end

-- MarkTaskUnfinished marks a task as unfinished.
function M.mark_task_unfinished()
	local line = vim.api.nvim_get_current_line()
	local sub, count = string.gsub(line, taskPattern, "%1- [ ]", 1)
	if count == 1 then
		vim.api.nvim_set_current_line(sub)
	end
end

-- mark_task_in_progress marks a task as in progress.
function M.mark_task_in_progress()
	local line = vim.api.nvim_get_current_line()
	local sub, count = string.gsub(line, taskPattern, "%1- [@]", 1)
	if count == 1 then
		vim.api.nvim_set_current_line(sub)
	end
end

-- mark_task_finished marks a task as finished.
function M.mark_task_finished()
	local line = vim.api.nvim_get_current_line()
	local sub, count = string.gsub(line, taskPattern, "%1- [X]", 1)
	if count == 1 then
		vim.api.nvim_set_current_line(sub)
	end
end

return M
