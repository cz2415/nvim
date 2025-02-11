-- close all floating
function CloseAllFloating()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local config = vim.api.nvim_win_get_config(win)
		if config.relative ~= "" then
			vim.api.nvim_win_close(win, false)
		end
	end
end

-- toggle gitgui
local Terminal = require("toggleterm.terminal").Terminal
local gitui = Terminal:new({
	cmd = "gitui",
	direction = "float",
	on_open = function()
		-- Stuff here
	end,
	hidden = true,
})
vim.api.nvim_create_user_command("ToggletermGitui", function()
	gitui:toggle()
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
