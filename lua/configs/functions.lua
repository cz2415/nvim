local M = {}

-- close all floating
-- function CloseAllFloating()
-- 	for _, win in ipairs(vim.api.nvim_list_wins()) do
-- 		local config = vim.api.nvim_win_get_config(win)
-- 		if config.relative ~= "" then
-- 			vim.api.nvim_win_close(win, false)
-- 		end
-- 	end
-- end

-- toggle lazygit
local Terminal = require("toggleterm.terminal").Terminal
local lazygit = Terminal:new({
	cmd = "lazygit",
	direction = "float",
	hidden = true,
	on_open = function(term)
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(term.bufnr) then
				vim.cmd("startinsert!")
			end
		end)
	end,
})
vim.api.nvim_create_user_command("ToggletermLazygit", function()
	lazygit:toggle()
end, { bang = true })

local function get_term_index(current_id, terms)
	local idx
	for i, v in ipairs(terms) do
		if v.id == current_id then
			idx = i
		end
	end
	return idx
end

local function go_prev_term()
	local current_id = vim.b.toggle_number
	if current_id == nil then
		return
	end

	local terms = require("toggleterm.terminal").get_all(true)
	local prev_index

	local index = get_term_index(current_id, terms)
	if index > 1 then
		prev_index = index - 1
	else
		prev_index = #terms
	end
	require("toggleterm").toggle(terms[index].id)
	require("toggleterm").toggle(terms[prev_index].id)
end

local function go_next_term()
	local current_id = vim.b.toggle_number
	if current_id == nil then
		return
	end

	local terms = require("toggleterm.terminal").get_all(true)
	local next_index

	local index = get_term_index(current_id, terms)
	if index == #terms then
		next_index = 1
	else
		next_index = index + 1
	end
	require("toggleterm").toggle(terms[index].id)
	require("toggleterm").toggle(terms[next_index].id)
end

vim.keymap.set({ "n", "t" }, "<F7>", function()
	go_prev_term()
end, { desc = "Toggle term" })

vim.keymap.set({ "n", "t" }, "<F8>", function()
	go_next_term()
end, { desc = "Toggle term" })

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

return M
