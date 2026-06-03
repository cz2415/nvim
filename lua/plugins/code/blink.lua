return {
	"saghen/blink.cmp",
	event = { "InsertEnter", "CmdlineEnter" },
	dependencies = {
		"rafamadriz/friendly-snippets",
		"saghen/blink.lib",
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
					columns = { { "kind_icon", gap = 1 }, { "label", gap = 1 }, { "kind_text" } },
					components = {
						kind_text = {
							text = function(ctx)
								return string.format("[%s]", ctx.kind)
							end,
							highlight = function(ctx)
								return "BlinkCmpKind" .. ctx.kind
							end,
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
			completion = { menu = { auto_show = true } },
		},
		fuzzy = {
			implementation = "lua",
			sorts = {
				function(a, b)
					local kind = require("blink.cmp.types").CompletionItemKind
					if a.kind == kind.Field and b.kind == kind.Snippet then
						return true
					end
					if a.kind == kind.Snippet and b.kind == kind.Field then
						return false
					end
				end,
				"score",
				"sort_text",
			},
		},
	},
}
