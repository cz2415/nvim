local common = require("configs.lsp.common")

local capabilities = common.capabilities
local on_attach = common.on_attach

local vue_language_server_path = common.mason_path .. "/vue-language-server/node_modules/@vue/language-server"
local vue_plugin = {
	name = "@vue/typescript-plugin",
	location = vue_language_server_path,
	languages = { "vue" },
	configNamespace = "typescript",
	enableForWorkspaceTypeScriptVersions = true,
}

vim.lsp.config("vtsls", {
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"vue",
	},
	settings = {
		vtsls = {
			tsserver = {
				globalPlugins = {
					vue_plugin,
				},
			},
		},
	},
})

vim.lsp.config("vue_ls", {
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "vue" },
	init_options = {
		vue = {
			hybridMode = false,
		},
	},
})

vim.lsp.config("eslint", {
	on_attach = function(client, bufnr)
		on_attach(client, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "EslintFixAll",
		})
	end,
	capabilities = capabilities,
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"vue",
	},
})

vim.lsp.config("html", {
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "html", "vue" },
})

vim.lsp.config("cssls", {
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "css", "scss", "less", "vue" },
})

vim.lsp.enable({
	"vtsls",
	"vue_ls",
	"eslint",
	"html",
	"cssls",
})
