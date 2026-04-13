local common = require("configs.lsp.common")

vim.lsp.config("pylsp", {
	on_attach = function() end,
	capabilities = common.capabilities,
	filetypes = { "python" },
	settings = {
		pylsp = {
			plugins = {
				mccabe = { enabled = false },
				pycodestyle = { enabled = false },
				pyflakes = { enabled = false },
			},
		},
	},
})

vim.lsp.enable({ "pylsp" })