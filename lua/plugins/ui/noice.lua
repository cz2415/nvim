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

		vim.keymap.set("n", "<C-f>", function()
			if not require("noice.lsp").scroll(4) then
				return "<C-f>"
			end
		end, { silent = true, expr = true, desc = "Scroll LSP docs down" })

		vim.keymap.set("n", "<C-b>", function()
			if not require("noice.lsp").scroll(-4) then
				return "<C-b>"
			end
		end, { silent = true, expr = true, desc = "Scroll LSP docs up" })
	end,
}
