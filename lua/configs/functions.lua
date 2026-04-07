local M = {}

-- close all floating
function CloseAllFloating()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local config = vim.api.nvim_win_get_config(win)
		if config.relative ~= "" then
			vim.api.nvim_win_close(win, false)
		end
	end
end

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

return M
