local common = require("configs.lsp.common")

vim.lsp.config("jsonls", {
	on_attach = common.on_attach,
	capabilities = common.capabilities,
	filetypes = { "json" },
	settings = {
		json = {
			validate = { enable = true },
		},
	},
})

vim.lsp.enable({ "jsonls" })
