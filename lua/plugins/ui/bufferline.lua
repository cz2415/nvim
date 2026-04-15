return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		{ "tiagovla/scope.nvim", config = true },
	},
	-- event = "VeryLazy",
	init = function()
		local opt = { noremap = true, silent = true }
		vim.api.nvim_set_keymap("n", "H", ":BufferLineCyclePrev<CR>", opt)
		vim.api.nvim_set_keymap("n", "L", ":BufferLineCycleNext<CR>", opt)
	end,
	config = function()
		require("bufferline").setup({
			options = {
				mode = "buffers",
				separator_style = "slant",
				indicator = {
					icon = "┃",
					style = "icon",
				},
			},
			highlights = {
				buffer_selected = {
					fg = "skyblue",
					bold = true,
					italic = true,
				},
			},
		})
	end,
}
