local function lazygit_edit_config()
	local server = vim.v.servername
	if server == nil or server == "" then
		return {
			editPreset = "",
			edit = 'nvim -- "{{filename}}"',
			editAtLine = 'nvim -- "+{{line}}" "{{filename}}"',
		}
	end

	server = server:gsub('"', '\\"')
	return {
		editPreset = "",
		edit = ('nvim --server "%s" --remote-send q && nvim --server "%s" --remote-tab "{{filename}}"'):format(
			server,
			server
		),
		editAtLine = ('nvim --server "%s" --remote-send q && nvim --server "%s" --remote-tab "+{{line}}" "{{filename}}"'):format(
			server,
			server
		),
	}
end

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		explorer = { enabled = true },
		lazygit = {
			enabled = true,
			config = {
				os = lazygit_edit_config(),
			},
		},
		quickfile = { enabled = true },
		picker = {
			enabled = true,
			ui_select = true,
			layout = {
				preset = "telescope",
			},
		},
		terminal = {
			enabled = true,
			win = {
				border = "rounded",
				position = "float",
			},
		},
	},
	keys = {},
	init = function() end,
}
