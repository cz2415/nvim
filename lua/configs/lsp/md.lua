vim.lsp.config("marksman", {
	on_attach = function() end,
	filetypes = { "markdown" },
})

vim.lsp.enable({ "markdown" })
