local M = {}

local status_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
local path_sep = package.config:sub(1, 1) == "\\" and ";" or ":"

if not vim.env.PATH:find(vim.pesc(mason_bin), 1) then
	vim.env.PATH = mason_bin .. path_sep .. vim.env.PATH
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion = vim.tbl_deep_extend("force", M.capabilities.textDocument.completion or {}, {
	completionItem = {
		commitCharactersSupport = false,
		deprecatedSupport = true,
		documentationFormat = { "markdown", "plaintext" },
		insertReplaceSupport = true,
		insertTextModeSupport = { valueSet = { 1, 2 } },
		labelDetailsSupport = true,
		preselectSupport = false,
		resolveSupport = {
			properties = {
				"documentation",
				"detail",
				"additionalTextEdits",
				"command",
				"data",
			},
		},
		snippetSupport = true,
		tagSupport = { valueSet = { 1 } },
	},
	completionList = {
		itemDefaults = {
			"commitCharacters",
			"editRange",
			"insertTextFormat",
			"insertTextMode",
			"data",
		},
	},
	contextSupport = true,
	dynamicRegistration = false,
	insertTextMode = 1,
})

if status_cmp then
	M.capabilities = cmp_nvim_lsp.default_capabilities(M.capabilities)
end

M.on_attach = function(client, bufnr) end

M.mason_path = vim.fn.stdpath("data") .. "/mason/packages"

return M
