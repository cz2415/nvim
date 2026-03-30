local capabilities = vim.lsp.protocol.make_client_capabilities()
local status_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if status_cmp then
	capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

vim.lsp.config("lua_ls", {
	on_attach = function() end,
	capabilities = capabilities,
	filetypes = { "lua" },
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true, -- 只扫描 Neovim 核心 lua
					[vim.fn.expand("$HOME/.config/nvim/lua")] = true, -- 你自己的配置
				},
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

vim.lsp.enable({ "lua_ls" })
