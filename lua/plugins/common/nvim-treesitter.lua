return {
	"nvim-treesitter/nvim-treesitter",
	version = false,
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require("nvim-treesitter.configs").setup({
			highlight = { enable = true, additional_vim_regex_highlighting = false },
			indent = { enable = true },
			incremental_selection = { enable = true },
			ensure_installed = {
				"html",
				"css",
				"java",
				"javascript",
				"json",
				"lua",
				"vue",
				"luadoc",
				"luap",
				"markdown",
				"markdown_inline",
				"python",
				"vim",
				"vimdoc",
				"http",
			},
		})
	end,
}
