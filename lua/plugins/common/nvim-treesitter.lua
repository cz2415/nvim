return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	init = function()
		vim.env.CC = "gcc"
	end,
	config = function()
		local parsers = {
			"sql",
			"html",
			"css",
			"java",
			"javascript",
			"typescript",
			"tsx",
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

		local filetypes = {
			"sql",
			"html",
			"css",
			"java",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"json",
			"lua",
			"vue",
			"markdown",
			"python",
			"vim",
			"help",
			"http",
			"regex",
		}

		local treesitter = require("nvim-treesitter")
		treesitter.setup()
		treesitter.install(parsers)

		vim.treesitter.language.register("javascript", "javascriptreact")
		vim.treesitter.language.register("tsx", "typescriptreact")

		vim.api.nvim_create_autocmd("FileType", {
			pattern = filetypes,
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
