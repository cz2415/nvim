local M = {}
local Snacks = require("snacks")

local saved_layout = nil
M.toggle_maximize = function()
	if saved_layout then
		-- 恢复布局
		-- vim.cmd(saved_layout)
		vim.cmd("wincmd =")
		saved_layout = nil
	else
		-- 保存布局
		saved_layout = vim.fn.winrestcmd()
		-- 最大化当前窗口
		vim.cmd("wincmd _")
		vim.cmd("wincmd |")
	end
end

local function get_visual_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local start_row, start_col = start_pos[2], start_pos[3]
	local end_row, end_col = end_pos[2], end_pos[3]

	if start_row > end_row or (start_row == end_row and start_col > end_col) then
		start_row, end_row = end_row, start_row
		start_col, end_col = end_col, start_col
	end

	local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
	if vim.tbl_isempty(lines) then
		return ""
	end

	lines[1] = string.sub(lines[1], start_col)
	if #lines == 1 then
		lines[1] = string.sub(lines[1], 1, end_col - start_col + 1)
	else
		lines[#lines] = string.sub(lines[#lines], 1, end_col)
	end

	return vim.trim(table.concat(lines, " "):gsub("%s+", " "))
end

M.live_grep_visual_selection = function()
	local text = get_visual_selection()
	if text == "" then
		vim.notify("No visual selection to search", vim.log.levels.WARN)
		return
	end

	require("snacks").picker.grep({ search = text })
end

local external_file_exts = {
	xlsx = true,
	xls = true,
	docx = true,
	doc = true,
	pptx = true,
	ppt = true,
	pdf = true,
}

local function clean_cfile(file)
	if file == nil then
		return ""
	end

	file = vim.trim(file)
	file = file:gsub("^<%s*", "")
	file = file:gsub("[%s,;:)%]]+$", "")
	return file:gsub("^[\"']", ""):gsub("[\"']$", "")
end

local function is_windows_absolute_path(file)
	return file:match("^%a:[/\\]") ~= nil or file:match("^\\\\") ~= nil
end

local function find_windows_file_on_line()
	local line = vim.api.nvim_get_current_line()
	local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1
	local fallback = nil

	local function check_pattern(pattern)
		for start_col, _, end_col in line:gmatch(pattern) do
			local file = clean_cfile(line:sub(start_col, end_col - 1))
			if cursor_col >= start_col and cursor_col <= end_col then
				return file
			end

			fallback = fallback or file
		end
	end

	-- expand("<cfile>") may drop the drive letter in Windows paths like D:\foo\bar.xlsx.
	local drive_file = check_pattern("()([%a]:[^\"'<>|%c]+)()")
	if drive_file then
		return drive_file
	end

	local unc_file = check_pattern("()(\\\\\\\\[^\"'<>|%c]+)()")
	if unc_file then
		return unc_file
	end

	return fallback
end

M.smart_gf = function()
	local file = find_windows_file_on_line() or clean_cfile(vim.fn.expand("<cfile>"))

	if file == "" then
		vim.cmd("normal! gf")
		return
	end

	local ext = vim.fn.fnamemodify(file, ":e"):lower()
	if external_file_exts[ext] then
		if vim.fn.filereadable(file) == 0 then
			vim.notify("File not found: " .. file, vim.log.levels.WARN)
			return
		end

		if vim.ui and vim.ui.open then
			vim.ui.open(file)
		else
			vim.fn.jobstart({ "cmd", "/c", "start", "", file }, { detach = true })
		end

		return
	end

	if is_windows_absolute_path(file) then
		if vim.fn.filereadable(file) == 0 then
			vim.notify("File not found: " .. file, vim.log.levels.WARN)
			return
		end

		vim.cmd.edit(vim.fn.fnameescape(file))
		return
	end

	vim.cmd("normal! gf")
end

local function run_from_terminal(callback)
	local mode = vim.api.nvim_get_mode().mode
	if mode:sub(1, 1) == "t" then
		vim.cmd.stopinsert()
		vim.schedule(callback)
		return
	end

	callback()
end

local last_snacks_terminal_count = 1
local terminal_win = { border = "rounded", position = "float" }

local function terminal_info(terminal)
	local info = vim.b[terminal.buf] and vim.b[terminal.buf].snacks_terminal or {}
	local id = type(info) == "table" and info.id or nil
	return type(info) == "table" and info or {}, id
end

local function terminal_name(terminal, id)
	return vim.b[terminal.buf].snacks_terminal_name or ("Terminal " .. tostring(id or "?"))
end

local function terminal_cmd(info)
	return type(info.cmd) == "table" and table.concat(info.cmd, " ") or info.cmd or vim.o.shell
end

local function is_lazygit_terminal(info)
	local cmd = terminal_cmd(info):lower()
	local first = vim.split(cmd, "%s+")[1] or ""
	local exe = vim.fn.fnamemodify(first, ":t"):lower()
	return exe == "lazygit" or exe == "lazygit.exe"
end

local function terminal_items()
	local items = {}
	for _, terminal in ipairs(Snacks.terminal.list()) do
		local info, id = terminal_info(terminal)
		if not is_lazygit_terminal(info) then
			items[#items + 1] = {
				text = string.format("%s  %s  %s", id or "?", terminal_name(terminal, id), info.cwd or vim.fn.getcwd()),
				terminal = terminal,
				id = id,
				buf = terminal.buf,
				name = terminal_name(terminal, id),
				cwd = info.cwd or vim.fn.getcwd(),
				cmd = terminal_cmd(info),
			}
		end
	end
	table.sort(items, function(a, b)
		return tostring(a.id or "") < tostring(b.id or "")
	end)
	return items
end

local function focus_terminal(terminal, id)
	if id then
		last_snacks_terminal_count = id
	end
	for _, other in ipairs(Snacks.terminal.list()) do
		if other ~= terminal and other:valid() then
			other:hide()
		end
	end
	terminal:show():focus()
	vim.cmd.startinsert()
end

local function close_terminal(terminal)
	if terminal and terminal:buf_valid() then
		terminal:close()
	end
end

M.toggle_snacks_terminal = function(count)
	run_from_terminal(function()
		local win = terminal_win

		if count ~= nil then
			last_snacks_terminal_count = count
			Snacks.terminal.toggle(nil, { count = count, win = win })
			return
		end

		local current_info = vim.b.snacks_terminal
		local has_current_count = type(current_info) == "table" and type(current_info.id) == "number"
		if has_current_count then
			last_snacks_terminal_count = current_info.id
		end

		local hidden = false
		for _, terminal in ipairs(Snacks.terminal.list()) do
			local info = vim.b[terminal.buf] and vim.b[terminal.buf].snacks_terminal or {}
			if terminal:valid() and not is_lazygit_terminal(info) then
				if not has_current_count and type(info) == "table" and type(info.id) == "number" then
					last_snacks_terminal_count = info.id
					has_current_count = true
				end
				terminal:hide()
				hidden = true
			end
		end

		if hidden then
			return
		end

		Snacks.terminal.toggle(nil, { count = last_snacks_terminal_count, win = win })
	end)
end

M.new_snacks_terminal = function()
	run_from_terminal(function()
		local used = {}
		for _, terminal in ipairs(Snacks.terminal.list()) do
			local _, id = terminal_info(terminal)
			if type(id) == "number" then
				used[id] = true
			end
		end

		local count = 1
		while used[count] do
			count = count + 1
		end

		last_snacks_terminal_count = count
		Snacks.terminal.toggle(nil, { count = count, win = terminal_win })
	end)
end

M.rename_snacks_terminal = function()
	run_from_terminal(function()
		local terminal = nil
		local current_info = vim.b.snacks_terminal
		if type(current_info) == "table" and type(current_info.id) == "number" then
			for _, item in ipairs(terminal_items()) do
				if item.id == current_info.id then
					terminal = item.terminal
					break
				end
			end
		end

		terminal = terminal or Snacks.terminal.get(nil, { count = last_snacks_terminal_count, create = false })
		if not terminal then
			vim.notify("No terminal to rename", vim.log.levels.WARN)
			return
		end

		local _, id = terminal_info(terminal)
		vim.ui.input({ prompt = "Terminal name: ", default = terminal_name(terminal, id) }, function(name)
			if name == nil then
				return
			end
			vim.b[terminal.buf].snacks_terminal_name = vim.trim(name) ~= "" and vim.trim(name) or nil
		end)
	end)
end

M.delete_current_snacks_terminal = function()
	run_from_terminal(function()
		local current_info = vim.b.snacks_terminal
		local terminal = nil
		if type(current_info) == "table" and type(current_info.id) == "number" then
			for _, item in ipairs(terminal_items()) do
				if item.id == current_info.id then
					terminal = item.terminal
					break
				end
			end
		end

		terminal = terminal or Snacks.terminal.get(nil, { count = last_snacks_terminal_count, create = false })
		if not terminal then
			vim.notify("No terminal to delete", vim.log.levels.WARN)
			return
		end

		close_terminal(terminal)
	end)
end

M.pick_snacks_terminal = function()
	run_from_terminal(function()
		local items = terminal_items()
		if #items == 0 then
			vim.notify("No terminals", vim.log.levels.WARN)
			return
		end

		Snacks.picker.pick({
			title = "Terminals",
			items = items,
			format = "text",
			preview = false,
			confirm = function(picker, item)
				picker:close()
				if item and item.terminal then
					vim.schedule(function()
						focus_terminal(item.terminal, item.id)
					end)
				end
			end,
			actions = {
				delete_terminal = function(picker, item)
					if item and item.terminal then
						close_terminal(item.terminal)
						picker:close()
						vim.schedule(M.pick_snacks_terminal)
					end
				end,
			},
			win = {
				input = {
					keys = {
						["d"] = { "delete_terminal", mode = { "n", "i" } },
					},
				},
				list = {
					keys = {
						["d"] = "delete_terminal",
					},
				},
			},
		})
	end)
end
M.open_snacks_lazygit = function()
	run_from_terminal(function()
		Snacks.lazygit.open()
	end)
end

return M
