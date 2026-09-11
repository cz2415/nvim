local common = require("configs.lsp.common")

vim.lsp.config("rust_analyzer", {
	on_attach = common.on_attach,
	capabilities = common.capabilities,
	filetypes = { "rust" },
	settings = {
		["rust-analyzer"] = {
			cargo = {
				allFeatures = true,
			},
			check = {
				command = "clippy",
			},
			procMacro = {
				enable = true,
			},
			files = {
				excludeDirs = {
					"node_modules",
					"dist",
					"target",
					"frontend",
				},
			},
		},
	},
})

vim.lsp.enable({ "rust_analyzer" })
