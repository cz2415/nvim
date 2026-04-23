local common = require("configs.lsp.common")

vim.lsp.config("pyright", {
	on_attach = common.on_attach,
	capabilities = common.capabilities,
	filetypes = { "python" },
	settings = {
		pyright = {
			disableOrganizeImports = false,
			analysis = {
				typeCheckingMode = "basic",
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
})

vim.lsp.enable({ "pyright" })