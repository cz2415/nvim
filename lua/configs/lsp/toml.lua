local common = require("configs.lsp.common")

vim.lsp.config("taplo", {
	on_attach = common.on_attach,
	capabilities = common.capabilities,
	filetypes = { "toml" },
})

vim.lsp.enable({ "taplo" })
