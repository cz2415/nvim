return {
	"saghen/blink.cmp",
	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	opts = {
		keymap = {
			preset = "enter",
			["<C-n>"] = { "show", "select_next", "fallback" },
			["<C-p>"] = { "show", "select_prev", "fallback" },
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		completion = {
			ghost_text = { enabled = true },
			menu = {
				border = "rounded",
				draw = {
					columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } },
					components = {
						source_name = {
							text = function(ctx)
								return ctx.source_name
							end,
							highlight = "Comment", -- 使用注释颜色，更柔和
						},
					},
				},
			},
			documentation = {
				auto_show = true,
				window = { border = "rounded" },
			},
			accept = { auto_brackets = { enabled = true } },
		},
		signature = { enabled = true },
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
		cmdline = {
			keymap = {
				preset = "cmdline",
				["<CR>"] = { "accept", "fallback" },
			},
			completion = { menu = { auto_show = true } },
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
}
