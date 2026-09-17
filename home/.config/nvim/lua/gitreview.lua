-- gitreview.lua provides a way to review all changes between your current working
-- tree and a target branch without including other changes introduced in between,
-- similar to a pull request view in Bitbucket or GitHub.
--
-- The view is created in a new tab split into three panels: a list of every
-- changed, added, renamed, and removed file at the bottom, with a split view above.
-- On the left hand side of the split view is the file as when the working tree
-- diverged from the target branch, and the right hand side contains the working
-- tree copy. Changes made to the target branch since then aren't shown,
-- so you only see what the working tree would introduce if a pull request is
-- made. Both file panels are in diff mode, so changes are highlighted and
-- unchanged regions are folded away.

local M = {
	-- last_branch is the branch that was most recently reviewed. It is used to
	-- prefill the branch picker for the rest of the session.
	last_branch = nil,
	-- list_height is the height of the file list panel at the bottom of the view.
	list_height = 12,
}

-- states holds the view state of every open review tab, keyed by tab handle.
-- This allows multiple review tabs to be open at the same time without
-- interfering with each other.
local states = {}

-- err is the common error message function for this module.
local function err(msg)
	vim.notify("gitreview: " .. msg, vim.log.levels.ERROR)
end

-- slug turns a path or a branch name into something usable as a single file name,
-- the same way 'undodir' names the files it keeps.
local function slug(s)
	return (s:gsub("/", "%%"))
end

local function cleanup_invalid_states()
	for tab, _ in pairs(states) do
		if not vim.api.nvim_tabpage_is_valid(tab) then
			states[tab] = nil
		end
	end
end

-- git runs a git command inside path and returns its output lines, or nil when
-- the command failed.
local function git(root, args)
	local cmd = { "git", "-C", root }
	for _, arg in ipairs(args) do
		table.insert(cmd, arg)
	end

	local out = vim.fn.systemlist(cmd)
	if vim.v.shell_error ~= 0 then
		return nil, table.concat(out, " ")
	end

	return out
end

-- git_ok runs a git command only for its exit status.
local function git_ok(root, args)
	return git(root, args) ~= nil
end

-- repo_root returns the top level directory of the repository containing the
-- current buffer, or nil when the buffer isn't inside a repository.
local function repo_root()
	-- The current buffer is not always a file on disk: the file list and the
	-- panels of an open review hold generated names, so fall back to the working
	-- directory for those.
	local dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
	if dir == "" or vim.fn.isdirectory(dir) == 0 then
		dir = vim.fn.getcwd()
	end

	local out = git(dir, { "rev-parse", "--show-toplevel" })
	if out == nil or out[1] == nil or out[1] == "" then
		return nil
	end

	return out[1]
end

-- head_name returns the name of the branch that is checked out, or the short commit
-- it is on when the head is detached.
local function head_name(root)
	local out = git(root, { "rev-parse", "--abbrev-ref", "HEAD" })
	if out ~= nil and out[1] ~= nil and out[1] ~= "" and out[1] ~= "HEAD" then
		return out[1]
	end

	out = git(root, { "rev-parse", "--short", "HEAD" })
	if out == nil or out[1] == nil then
		return "HEAD"
	end

	return out[1]
end

-- comment_file returns the path of the markdown file the comments of a review are
-- written in, and creates the directory it belongs in. Reviews of the same two
-- branches share a file, so reopening one picks up the comments left last time.
local function comment_file(root, head, branch)
	local dir = vim.fn.stdpath("data") .. "/gitreview/" .. slug(root)
	vim.fn.mkdir(dir, "p")

	return dir .. "/" .. slug(head) .. ".." .. slug(branch) .. ".md"
end

-- prefill_picker returns the branch name the picker should start with: the last branch
-- reviewed this session, otherwise the branch that was checked out before the
-- current one.
local function prefill_picker(root)
	if M.last_branch ~= nil then
		return M.last_branch
	end

	local out = git(root, { "rev-parse", "--abbrev-ref", "@{-1}" })
	if out == nil or out[1] == nil or out[1] == "@{-1}" then
		return ""
	end

	-- Reviewing a branch against itself never shows anything, which happens when
	-- the previous checkout was the branch that is checked out now.
	local head = git(root, { "rev-parse", "--abbrev-ref", "HEAD" })
	if head ~= nil and head[1] == out[1] then
		return ""
	end

	return out[1]
end

-- changed_files returns an entry per file that differs between base and the
-- working tree.
local function changed_files(root, base)
	local out, msg = git(root, { "diff", "--name-status", "--find-renames", base })
	if out == nil then
		return nil, msg
	end

	local entries = {}
	for _, line in ipairs(out) do
		local fields = vim.split(line, "\t", { plain = true })
		local status = fields[1]
		if status ~= nil and fields[2] ~= nil then
			-- Rename and copy statuses carry a similarity score (R100) and both
			-- an old and a new path.
			local letter = status:sub(1, 1)
			if letter == "R" or letter == "C" then
				table.insert(entries, {
					status = letter,
					path = fields[3],
					old_path = fields[2],
				})
			else
				table.insert(entries, {
					status = letter,
					path = fields[2],
				})
			end
		end
	end

	return entries
end

-- rev_path returns the path an entry had on the target side of the diff.
local function rev_path(entry)
	return entry.old_path or entry.path
end

local function display_path(entry)
	if entry.old_path ~= nil then
		return entry.old_path .. " -> " .. entry.path
	end

	return entry.path
end

-- find_scratch returns the scratch buffer previously created for name, or nil.
-- Neovim resolves buffer names against the working directory, so the name a
-- buffer reports back is not always the one it was given.
local function find_scratch(name)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buftype == "nofile" then
			local got = vim.api.nvim_buf_get_name(buf)
			if got == name or vim.endswith(got, "/" .. name) then
				return buf
			end
		end
	end

	return nil
end

-- scratch_buf creates an empty unlisted buffer to stand in for a file that is
-- missing from one side of the diff. An existing buffer of the same name is
-- reused, since the same entry can be opened more than once.
local function scratch_buf(name, filetype)
	local buf = find_scratch(name)
	if buf == nil then
		buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(buf, name)
	end

	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	-- Nothing in a panel is ever edited, and a read only buffer is also what makes
	-- it safe to bind keys that would otherwise have changed the text.
	vim.bo[buf].modifiable = false
	if filetype ~= nil and filetype ~= "" then
		vim.bo[buf].filetype = filetype
	end

	return buf
end

-- render_list draws the file list panel.
local function render_list(state)
	local ns = vim.api.nvim_create_namespace("review")
	local lines = {}
	for _, entry in ipairs(state.entries) do
		table.insert(lines, entry.status .. "  " .. display_path(entry))
	end

	vim.bo[state.list_buf].modifiable = true
	vim.api.nvim_buf_set_lines(state.list_buf, 0, -1, false, lines)
	vim.bo[state.list_buf].modifiable = false

	vim.api.nvim_buf_clear_namespace(state.list_buf, ns, 0, -1)
	for i, entry in ipairs(state.entries) do
		local hl = nil
		if entry.status == "A" then
			hl = "diffAdded"
		elseif entry.status == "D" then
			hl = "diffRemoved"
		end

		if hl ~= nil then
			vim.api.nvim_buf_set_extmark(state.list_buf, ns, i - 1, 0, {
				end_col = #lines[i],
				hl_group = hl,
			})
		end
	end
end

-- is_binary reports whether git considers a path binary, in which case there is
-- no line based diff to put in the panels. `git diff --numstat` prints the added
-- and deleted line counts of each file separated by tabs, and prints a dash in
-- place of both counts when the file is binary:
--
--     5   1   keep.txt   (text)
--     -   -   blob.bin   (binary)
--
-- so the pair of leading dashes is the marker being matched here.
local function is_binary(state, entry)
	local out = git(state.root, { "diff", "--numstat", state.base, "--", entry.path })
	if out == nil or out[1] == nil then
		return false
	end

	return out[1]:match("^%-\t%-\t") ~= nil
end


-- open_comment_file opens the comment file of a review beside the file list, or
-- moves to it when it is open already. Splitting the list rather than a panel keeps
-- the diff the full width of the tab.
local function open_comment_file(state)
	if state.comment_win ~= nil and vim.api.nvim_win_is_valid(state.comment_win) then
		vim.api.nvim_set_current_win(state.comment_win)
		return
	end

	local fresh = vim.fn.filereadable(state.comment_path) == 0

	vim.api.nvim_set_current_win(state.list_win)
	vim.cmd("rightbelow vsplit " .. vim.fn.fnameescape(state.comment_path))
	state.comment_win = vim.api.nvim_get_current_win()

	-- A split inherits the window options of the window it came from, and the file
	-- list is not a file window, so the ones it changes go back to the values a
	-- window is normally created with. 'winfixheight' is left inherited on purpose:
	-- it keeps the bottom row from being resized along with the panels.
	vim.api.nvim_win_call(state.comment_win, function()
		vim.cmd("setlocal number< cursorline< signcolumn< statusline<")
	end)

	-- A comment file that has never been written starts from a header naming what
	-- is being compared. The buffer is left unwritten, so a review you comment
	-- nothing on leaves no file behind either.
	if fresh then
		vim.api.nvim_buf_set_lines(0, 0, -1, false, {
			"# Review: " .. state.head .. " against " .. state.branch,
			"",
		})
	end
end

-- comment_at_cursor writes a heading naming the lines under the cursor into the
-- comment file and leaves the cursor below it, ready to be written under. The
-- position is a line and a column, followed by a second one after a dash when a
-- visual selection covers more than a single line.
local function comment_at_cursor(state, side)
	local entry = state.entries[state.current or 0]
	if entry == nil then
		return
	end

	-- The panel is read before anything moves the cursor off it, since the code
	-- being commented on is copied out of it further down.
	local panel = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local first_line, first_col = cursor[1], cursor[2] + 1
	local last_line, last_col = first_line, first_col

	-- In visual mode the marks of the selection are not set yet, but the end the
	-- cursor is not on is in the v mark. Either end can be the earlier one.
	if vim.fn.mode():match("^[vV\22]") ~= nil then
		local other = vim.fn.getpos("v")
		if other[2] < first_line or (other[2] == first_line and other[3] < first_col) then
			first_line, first_col, last_line, last_col = other[2], other[3], first_line, first_col
		else
			last_line, last_col = other[2], other[3]
		end

		-- The x flag leaves visual mode now rather than queueing the escape until
		-- after the cursor has moved to the comment file.
		vim.api.nvim_feedkeys(vim.keycode("<esc>"), "nx", false)
	end

	-- Each panel names the file the way its own side of the diff does, which is not
	-- the same name on both sides of a rename.
	local path = side == "merge-base" and rev_path(entry) or entry.path
	local heading = "## " .. path .. ":" .. first_line .. ":" .. first_col

	-- Don't render ending line or column if they aren't set
	-- from a visual selection.
	if last_line > first_line then
		heading = heading .. "-" .. last_line .. ":" .. last_col
	end

	heading = heading .. " @ " .. side

	-- The lines being commented on are copied in below the heading, so the comment
	-- file reads on its own. The fence is tagged with the file type of the panel it
	-- came from, which is the same one that highlighted it there.
	local code = vim.api.nvim_buf_get_lines(panel, first_line - 1, last_line, false)

	-- A fence has to be longer than any run of backticks inside it, or the block
	-- ends early. Reviewing markdown is what runs into this.
	local ticks = 3
	for _, line in ipairs(code) do
		for run in line:gmatch("`+") do
			ticks = math.max(ticks, #run + 1)
		end
	end
	local fence = string.rep("`", ticks)

	open_comment_file(state)

	local buf = vim.api.nvim_win_get_buf(state.comment_win)
	local at = vim.api.nvim_buf_line_count(buf)
	local lines = { heading, fence .. vim.bo[panel].filetype }
	vim.list_extend(lines, code)
	table.insert(lines, fence)
	table.insert(lines, "")

	-- Keep a blank line between whatever was written under the previous heading and
	-- this one.
	local tail = vim.api.nvim_buf_get_lines(buf, at - 1, at, false)[1]
	if tail ~= nil and tail ~= "" then
		table.insert(lines, 1, "")
	end

	vim.api.nvim_buf_set_lines(buf, at, at, false, lines)
	vim.api.nvim_win_set_cursor(state.comment_win, { at + #lines, 0 })
end

-- setup_panel names a panel in its status line. The buffers are replaced for every
-- entry, so this runs again for each of them.
--
-- Nothing is bound in the panels and nothing is made read only there. The right
-- panel holds the real buffer of the working tree file, so the language server and
-- everything else that works off a path work in it, and trying a change out while
-- reading is part of reviewing. Both 'modifiable' and a buffer local mapping belong
-- to the buffer rather than to the window, so either one would have followed that
-- file into every other window showing it.
local function setup_panel(win, side, entry)
	-- Each panel names its side as well as the file, since a rename does not have
	-- the same name on both of them.
	local label = (side == "merge-base" and rev_path(entry) or entry.path) .. " @ " .. side
	vim.api.nvim_set_option_value("statusline",
		"%<" .. label:gsub("%%", "%%%%") .. " ",
		{ win = win, scope = "local" })
end

-- load_entry loads the file at index idx into the two diff panels.
local function load_entry(state, idx)
	local entry = state.entries[idx]
	if entry == nil then
		return
	end

	-- Bail before touching the panels so the file being reviewed stays put.
	if is_binary(state, entry) then
		err("binary file: " .. entry.path)
		return
	end

	-- Leave diff mode everywhere in this tab before swapping the buffers out so
	-- no stale diff settings are left behind on the buffers being replaced.
	vim.api.nvim_win_call(state.base_win, function()
		vim.cmd("diffoff!")
	end)

	local abs = state.root .. "/" .. entry.path
	local filetype = vim.filetype.match({ filename = entry.path }) or ""

	-- Right panel: the file as it exists in the working tree. It is the real buffer
	-- of the file rather than a copy, so that the language server, tags and
	-- everything else that works off a path work here too.
	vim.api.nvim_win_call(state.work_win, function()
		if vim.fn.filereadable(abs) == 1 then
			vim.cmd("edit " .. vim.fn.fnameescape(abs))
		else
			vim.api.nvim_win_set_buf(0, scratch_buf(entry.path .. " (deleted)", filetype))
		end
	end)

	-- Left panel: the file as it was at the merge base.
	local revspec = state.base .. ":" .. rev_path(entry)
	vim.api.nvim_win_call(state.base_win, function()
		if git_ok(state.root, { "cat-file", "-e", revspec }) then
			vim.cmd("edit " .. vim.fn.fnameescape(vim.fn.FugitiveFind(revspec, state.git_dir)))
			vim.bo.bufhidden = "wipe"
			vim.bo.modifiable = false
		else
			vim.api.nvim_win_set_buf(0, scratch_buf(revspec .. " (new file)", filetype))
		end
	end)

	-- Diff mode sets 'foldmethod' and enables folds window-locally, but if a
	-- config disables folds globally they are set here explicitly to be safe.
	for _, win in ipairs({ state.work_win, state.base_win }) do
		vim.api.nvim_win_call(win, function()
			vim.cmd("diffthis")
			vim.cmd("setlocal foldmethod=diff foldenable foldlevel=0")
		end)
	end

	-- Diff folds are built the first time the diff is drawn, and opening a review
	-- from inside the Telescope action skips that, leaving both panels unfolded
	-- while the picker is still closing its windows. Asking for one update once the
	-- event loop is free again builds them for both panels.
	vim.schedule(function()
		if vim.api.nvim_win_is_valid(state.work_win) then
			vim.api.nvim_win_call(state.work_win, function()
				vim.cmd("diffupdate")
			end)
		end
	end)

	setup_panel(state.base_win, "merge-base", entry)
	setup_panel(state.work_win, "working-tree", entry)

	state.current = idx
	vim.api.nvim_set_current_win(state.list_win)
	vim.api.nvim_win_set_cursor(state.list_win, { idx, 0 })
end

-- refresh recomputes the diff and redraws the file list.
local function refresh(state)
	local entries, msg = changed_files(state.root, state.base)
	if entries == nil then
		err("could not diff against " .. state.branch .. ": " .. msg)
		return
	end

	if #entries == 0 then
		err("no changes against " .. state.branch)
		return
	end

	state.entries = entries
	render_list(state)

	local idx = math.min(state.current or 1, #entries)
	load_entry(state, idx)
end

-- teardown closes the whole review. The two panels and the file list only mean
-- anything together, so closing any one of them takes the other two with it.
local function teardown(state)
	-- Closing the windows below fires WinClosed for each of them, which leads
	-- straight back here.
	if state.closing then
		return
	end
	state.closing = true

	-- A window cannot be closed from inside the WinClosed autocmd that led here,
	-- so the work waits for the next turn of the event loop.
	vim.schedule(function()
		pcall(vim.api.nvim_del_augroup_by_id, state.augroup)

		-- The comment file is not one of the windows that close each other, so it
		-- is only listed here, where the review is going away regardless.
		for _, win in ipairs({ state.base_win, state.work_win, state.list_win, state.comment_win }) do
			if vim.api.nvim_win_is_valid(win) then
				-- Leaving diff mode first matters for the window that cannot be
				-- closed, which is the last one of the session.
				vim.api.nvim_win_call(win, function() vim.cmd("diffoff") end)
				if not pcall(vim.api.nvim_win_close, win, true) then
					vim.api.nvim_win_call(win, function() vim.cmd("enew") end)
				end
			end
		end

		states[state.tab] = nil
	end)
end

-- list_bindings returns the key-bindings of the file list. They are described here
-- rather than set directly so the status line hint cannot drift from them. Only
-- the first key of an entry is named in the hint, the rest are alternatives.
local function list_bindings(state)
	return {
		{
			keys = { "<enter>", "<2-LeftMouse>" },
			description = "open",
			fn = function()
				load_entry(state, vim.api.nvim_win_get_cursor(state.list_win)[1])
			end,
		},
		{
			keys = { "c" },
			description = "comment",
			fn = M.comment,
		},
		{
			keys = { "r" },
			description = "refresh",
			fn = function() refresh(state) end,
		},
		{
			keys = { "q" },
			description = "close",
			fn = function() teardown(state) end,
		},
	}
end

-- setup_list configures the file list buffer and its key-bindings.
local function setup_list(state)
	local buf = state.list_buf

	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "gitreview"
	-- The tab handle keeps the name unique when several reviews are open, while
	-- leaving the branch as the last path component so it is what the tab line
	-- ends up displaying.
	vim.api.nvim_buf_set_name(buf, "gitreview://" .. state.tab .. "/" .. state.branch)

	vim.api.nvim_set_option_value("number", false, { win = state.list_win, scope = "local" })
	vim.api.nvim_set_option_value("cursorline", true, { win = state.list_win, scope = "local" })
	vim.api.nvim_set_option_value("signcolumn", "no", { win = state.list_win, scope = "local" })
	vim.api.nvim_set_option_value("winfixheight", true, { win = state.list_win, scope = "local" })

	local opts = { buffer = buf, noremap = true, silent = true, nowait = true }
	local hints = {}
	for _, mapping in ipairs(list_bindings(state)) do
		for _, key in ipairs(mapping.keys) do
			vim.keymap.set("n", key, mapping.fn, opts)
		end
		table.insert(hints, mapping.keys[1] .. "=" .. mapping.description)
	end

	-- A percent sign is a format item in a status line, so anything taken from
	-- the repository has to be escaped before it goes in one.
	local branch = state.branch:gsub("%%", "%%%%")
	-- The merge base is named here rather than in a panel because it belongs to the
	-- whole review, and because it is the one thing on screen that says which commit
	-- the comparison is anchored to. Reviewing the same branch again once the target
	-- has moved on gives a different one.
	vim.api.nvim_set_option_value("statusline",
		"Changes against " .. branch .. " (" .. state.base:sub(1, 7) .. ")"
		.. " %=" .. table.concat(hints, "   ") .. " ",
		{ win = state.list_win, scope = "local" })
end

-- build_layout creates the review tab and returns its state.
local function build_layout(root, git_dir, head, branch, base, entries)
	vim.cmd("tabnew")
	local tab = vim.api.nvim_get_current_tabpage()
	local base_win = vim.api.nvim_get_current_win()

	-- The file list spans the full width below both file panels.
	vim.cmd("botright " .. M.list_height .. "split")
	local list_win = vim.api.nvim_get_current_win()
	local list_buf = vim.api.nvim_get_current_buf()

	-- The working tree side goes to the right of the target side, the way the
	-- side-by-side views of the git forges lay a diff out.
	vim.api.nvim_set_current_win(base_win)
	vim.cmd("rightbelow vsplit")
	local work_win = vim.api.nvim_get_current_win()

	local state = {
		tab = tab,
		root = root,
		git_dir = git_dir,
		head = head,
		branch = branch,
		base = base,
		entries = entries,
		comment_path = comment_file(root, head, branch),
		base_win = base_win,
		work_win = work_win,
		list_win = list_win,
		list_buf = list_buf,
	}
	states[tab] = state

	-- The pattern of a WinClosed event is the id of the window being closed, so
	-- this only ever fires for the three windows of this review. The group is
	-- created per review to keep the module free of load time side effects, and
	-- is deleted again by the teardown it triggers.
	state.augroup = vim.api.nvim_create_augroup("review-" .. tab, { clear = true })
	vim.api.nvim_create_autocmd("WinClosed", {
		group = state.augroup,
		pattern = { tostring(base_win), tostring(work_win), tostring(list_win) },
		callback = function() teardown(state) end,
	})

	return state
end

-- open_against builds the review view comparing the working tree against the
-- merge base with branch.
function M.open_against(branch)
	-- First do some housekeeping to cleanup
	-- any stale review states.
	cleanup_invalid_states()

	local root = repo_root()
	if root == nil then
		err("not inside a git repository")
		return
	end

	local out, msg = git(root, { "merge-base", branch, "HEAD" })
	if out == nil or out[1] == nil or out[1] == "" then
		err("no merge base with " .. branch .. ": " .. (msg or "unknown error"))
		return
	end
	local base = out[1]

	-- Fugitive addresses objects by git dir, which is not the work tree root.
	out = git(root, { "rev-parse", "--absolute-git-dir" })
	if out == nil or out[1] == nil then
		err("could not resolve the git directory of " .. root)
		return
	end
	local git_dir = out[1]

	local entries
	entries, msg = changed_files(root, base)
	if entries == nil then
		err("could not diff against " .. branch .. ": " .. msg)
		return
	end

	if #entries == 0 then
		vim.notify("gitreview: no changes against " .. branch)
		return
	end

	M.last_branch = branch

	local state = build_layout(root, git_dir, head_name(root), branch, base, entries)
	setup_list(state)
	render_list(state)
	load_entry(state, 1)
end

-- comment opens the comment file of the review in this tab as a panel of its own.
function M.comment()
	local state = states[vim.api.nvim_get_current_tabpage()]
	if state == nil then
		err("not in a gitreview")
		return
	end

	open_comment_file(state)
end

-- comment_line opens the comment file the way comment does, and writes a heading
-- naming the lines under the cursor first. It works out which panel it was called
-- from, so it says where it is rather than guessing when it is called anywhere else.
function M.comment_line()
	local state = states[vim.api.nvim_get_current_tabpage()]
	if state == nil then
		err("not in a gitreview")
		return
	end

	local win = vim.api.nvim_get_current_win()
	if win == state.base_win then
		comment_at_cursor(state, "merge-base")
	elseif win == state.work_win then
		comment_at_cursor(state, "working-tree")
	else
		err("not in one of the diff panels")
	end
end

-- select_branch picks the branch to review against using Telescope.
function M.select_branch()
	local root = repo_root()
	if root == nil then
		err("not inside a git repository")
		return
	end

	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	require("telescope.builtin").git_branches({
		prompt_title = "Review diff against branch",
		cwd = root,
		default_text = prefill_picker(root),
		attach_mappings = function(prompt_bufnr, _)
			-- The default action checks the branch out, which is never wanted here.
			actions.select_default:replace(function()
				local entry = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				if entry == nil then return end

				M.open_against(entry.value)
			end)

			return true
		end,
	})
end

return M
