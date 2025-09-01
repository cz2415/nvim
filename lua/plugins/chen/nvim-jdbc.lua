return {
	"nvim-jdbc",
	dir = "D:\\chen\\code\\lua\\nvim-jdbc\\",
	config = function()
		require("nvim-jdbc").setup({
			keymap = "<leader>hello",
		})
	end,
}
