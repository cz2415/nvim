vim.lsp.config("pylsp", {
	on_attach = function() end,
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
