return {
	"stevearc/conform.nvim",
	-- event = {"BufWritePre"},
	cmd = { "ConformInfo" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { { "stylua" } },
				json = { { "prettier" } },
				markdown = { { "prettier" } },
				css = { { "prettier" } },
				scss = { { "prettier" } },
				html = { { "prettier" } },
				javascriptreact = { { "prettier" } },
				javascript = { { "prettier" } },
				vue = { { "prettier" } },
				python = { { "black" } },
			},
		})
	end,
}
