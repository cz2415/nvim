return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	init = function()
		vim.env.CC = "gcc"
	end,
	config = function()
		local ft = {
			"sql",
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
			"regex",
		}

		local treesitter = require("nvim-treesitter")
		treesitter.setup()
		treesitter.install(ft)

		vim.api.nvim_create_autocmd("FileType", {
			pattern = ft,
			callback = function()
				-- syntax highlighting, provided by Neovim
				vim.treesitter.start()
				-- folds, provided by Neovim (I don't like folds)
				-- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
				-- vim.wo.foldmethod = 'expr'
				-- indentation, provided by nvim-treesitter
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
