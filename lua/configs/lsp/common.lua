local M = {}

local status_blink, blink_cmp = pcall(require, "blink.cmp")
local status_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")

M.capabilities = vim.lsp.protocol.make_client_capabilities()

if status_blink then
	M.capabilities = blink_cmp.get_lsp_capabilities(M.capabilities)
elseif status_cmp then
	M.capabilities = cmp_nvim_lsp.default_capabilities(M.capabilities)
end

M.on_attach = function(client, bufnr) end

M.mason_path = vim.fn.stdpath("data") .. "/mason/packages"

return M
