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
	on_init = function(client)
		local retries = 0

		local function typescriptHandler(_, result, context)
			local ts_client = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })[1]
				or vim.lsp.get_clients({ bufnr = context.bufnr, name = "ts_ls" })[1]

			if not ts_client then
				if retries <= 10 then
					retries = retries + 1
					vim.defer_fn(function()
						typescriptHandler(_, result, context)
					end, 100)
				else
					vim.notify(
						"Could not find `vtsls` lsp client required by `vue_ls`.",
						vim.log.levels.ERROR
					)
				end
				return
			end

			local param = unpack(result)
			local id, command, payload = unpack(param)
			ts_client:exec_cmd({
				title = "vue_request_forward",
				command = "typescript.tsserverRequest",
				arguments = {
					command,
					payload,
				},
			}, { bufnr = context.bufnr }, function(_, r)
				client:notify("tsserver/response", { { id, r and r.body } })
			end)
		end

		client.handlers["tsserver/request"] = typescriptHandler
	end,
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
	filetypes = { "html" },
})

vim.lsp.config("cssls", {
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "css", "scss", "less" },
})

vim.lsp.enable({
	"vtsls",
	"vue_ls",
	"eslint",
	"html",
	"cssls",
})
