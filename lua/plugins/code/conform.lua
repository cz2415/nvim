return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				json = { "prettier" },
				json5 = { "prettier" },
				markdown = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				html = { "prettier" },
				javascriptreact = { "prettier" },
				javascript = { "prettier" },
				vue = { "prettier" },
				python = { "black" },
				sql = { "sql_formatter" },
			},
			formatters = {
				sql_formatter = {
					command = "sql-formatter",
					args = { "-l", "sql" },
					stdin = true,
				},
			},
		})
	end,
}
