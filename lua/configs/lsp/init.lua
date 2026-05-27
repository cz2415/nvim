local lsp_files = {
	"lua",
	"js",
	"py",
	"md",
	"java",
	"json",
}

for _, file in ipairs(lsp_files) do
	require("configs.lsp." .. file)
end

-- 配置诊断显示样式（直接在 config 里设置图标）
vim.diagnostic.config({
	virtual_text = false, -- 关闭虚拟文本显示
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.HINT] = "",
			[vim.diagnostic.severity.INFO] = "",
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded", -- 圆角边框
		source = "if_many", -- 显示来源
		header = "",
		prefix = "",
	},
})

-- 自动高亮光标下内容的引用, 并在光标移动时清除
local lsp_highlight_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then
			return
		end

		-- 自动 attach navic
		if client.server_capabilities.documentSymbolProvider then
			local ok, navic = pcall(require, "nvim-navic")
			if ok then
				navic.attach(client, args.buf)
			end
		end

		if client.server_capabilities.documentHighlightProvider then
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = args.buf,
				group = lsp_highlight_group,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd("CursorMoved", {
				buffer = args.buf,
				group = lsp_highlight_group,
				callback = vim.lsp.buf.clear_references,
			})
		end
	end,
})

vim.api.nvim_create_autocmd("BufLeave", {
	group = lsp_highlight_group,
	callback = vim.lsp.buf.clear_references,
})
