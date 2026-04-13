local common = require("configs.lsp.common")

vim.lsp.config("marksman", {
	on_attach = function() end,
	capabilities = common.capabilities,
	filetypes = { "markdown" },
})

vim.lsp.enable({ "marksman" })
