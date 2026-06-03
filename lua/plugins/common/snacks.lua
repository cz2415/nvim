return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		explorer = { enabled = true },
		quickfile = { enabled = true },
		picker = {
			enabled = true,
			ui_select = true,
			layout = {
				preset = "telescope",
			},
		},
	},
	keys = {},
	init = function() end,
}
