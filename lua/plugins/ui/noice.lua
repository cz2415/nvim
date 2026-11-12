return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {},
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- OPTIONAL:
		-- `nvim-notify` is only needed, if you want to use the notification view.
		-- If not available, we use `mini` as the fallback
		{
			"rcarriga/nvim-notify",
			config = function()
				require("notify").setup({
					background_colour = "#000000",
				})
			end,
		},
	},
	config = function()
		require("noice").setup({
			routes = {
				{
					filter = {
						event = "notify",
						find = "No information available",
					},
					opts = {
						skip = true,
					},
				},
			},

			lsp = {
				-- jdtls 等的 $/progress 进度不再弹 mini 框 (状态栏 lualine lsp_status 可看)
				progress = {
					enabled = false,
				},
				-- hover 交给 nvim 0.12 原生实现: keymaps.lua 的 K toggle 依赖原生的
				-- lsp_floating_preview / textDocument/hover 变量, noice 接管后这些变量不存在
				hover = {
					enabled = false,
				},
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = false, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = false, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = true, -- add a border to hover docs and signature help
			},
		})

		-- 滚动 LSP 文档浮窗: 原生 hover 浮窗优先, 其次 noice 管的窗口 (signature), 都没有则透传原键
		-- 注意: 映射必须是普通模式而非 expr 模式 — expr 求值期间有 textlock, :normal 会报 E523
		local function scroll_lsp_doc(down)
			local win = vim.b.lsp_floating_preview
			if win and vim.api.nvim_win_is_valid(win) then
				local key = vim.api.nvim_replace_termcodes(down and "<C-d>" or "<C-u>", true, false, true)
				vim.fn.win_execute(win, "normal! " .. key)
				return true
			end
			local ok, res = pcall(function()
				return require("noice.lsp").scroll(down and 20 or -20)
			end)
			if ok and res then
				return true
			end
			-- 透传: noremap 模式 feedkeys 不会重新触发本映射, 执行原生翻页
			local key = vim.api.nvim_replace_termcodes(down and "<C-f>" or "<C-b>", true, false, true)
			vim.api.nvim_feedkeys(key, "n", false)
			return true
		end

		vim.keymap.set("n", "<C-f>", function()
			scroll_lsp_doc(true)
		end, { silent = true, desc = "Scroll LSP docs down" })

		vim.keymap.set("n", "<C-b>", function()
			scroll_lsp_doc(false)
		end, { silent = true, desc = "Scroll LSP docs up" })
	end,
}
