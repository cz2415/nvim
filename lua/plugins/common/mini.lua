return {
	{
		"nvim-mini/mini.animate",
		version = "*",
		opts = function()
			local mouse_scrolled = false
			for _, scroll in ipairs({ "Up", "Down" }) do
				local key = "<ScrollWheel" .. scroll .. ">"
				vim.keymap.set({ "", "i" }, key, function()
					mouse_scrolled = true
					return key
				end, { expr = true })
			end

			local animate = require("mini.animate")
			return {
				resize = {
					timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),
				},
				scroll = {
					timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
					subscroll = animate.gen_subscroll.equal({
						predicate = function(total_scroll)
							if mouse_scrolled then
								mouse_scrolled = false
								return false
							end
							return total_scroll > 1
						end,
					}),
				},
			}
		end,
	},
	{
		"nvim-mini/mini.files",
		event = "VeryLazy",
		version = "*",
		config = function()
			require("mini.files").setup({
				windows = {
					max_number = math.huge,
					preview = true,
					width_focus = 50,
					width_nofocus = 15,
					width_preview = 55,
				},
				mappings = {
					synchronize = "<C-s>",
				},
			})
		end,
	},
	{
		"nvim-mini/mini.align",
		version = "*",
		config = function()
			require("mini.align").setup()
		end,
	},
	{
		"nvim-mini/mini.sessions",
		version = "*",
		config = function()
			require("mini.sessions").setup({
				autoread = true,
				autowrite = true,
				directory = vim.fn.stdpath("data") .. "/session",
				file = "",
				force = { read = false, write = true, delete = true },
				hooks = {
					pre = {
						-- remove no-name buffers before write
						write = function()
							for _, buf in ipairs(vim.api.nvim_list_bufs()) do
								if vim.api.nvim_buf_get_name(buf) == "" then
									vim.api.nvim_buf_delete(buf, { force = true })
								end
							end
						end,
					},
					post = {
						-- remove no-name buffers after read
						read = function()
							for _, buf in ipairs(vim.api.nvim_list_bufs()) do
								if vim.api.nvim_buf_get_name(buf) == "" then
									vim.api.nvim_buf_delete(buf, { force = true })
								end
							end
						end,
					},
				},
			})
		end,
	},
}
