return {
	"SmiteshP/nvim-navbuddy",
	dependencies = {
		"SmiteshP/nvim-navic",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		local function snacks_picker()
			return {
				callback = function(display)
					local navic = require("nvim-navic.lib")
					local children = display.focus_node.parent and display.focus_node.parent.children or {}
					if vim.tbl_isempty(children) then
						vim.notify("No symbols at current level", vim.log.levels.WARN)
						return
					end

					local items = vim.tbl_map(function(node)
						local kind = navic.adapt_lsp_num_to_str(node.kind)
						local range = node.name_range["start"]
						return {
							text = string.format("%s %s", string.lower(kind), node.name),
							node = node,
							kind = kind,
							name = node.name,
							file = vim.api.nvim_buf_get_name(display.for_buf),
							buf = display.for_buf,
							pos = { range.line, range.character },
							lnum = range.line,
							col = range.character + 1,
						}
					end, children)

					display:close()
					require("snacks").picker({
						title = "Navbuddy Symbols",
						items = items,
						format = function(item)
							return {
								{ item.kind:lower(), "Navbuddy" .. item.kind },
								{ " " },
								{ item.name, "NavbuddyNormalFloat" },
							}
						end,
						confirm = function(picker, item)
							if item then
								display.focus_node = item.node
							end
							picker:close()
						end,
						on_close = function()
							require("nvim-navbuddy.display"):new(display)
						end,
					})
				end,
				description = "Fuzzy search current level with snacks",
			}
		end

		require("nvim-navbuddy").setup({
			lsp = { auto_attach = true },
			window = {
				size = "80%",
			},
			mappings = {
				["t"] = snacks_picker(),
			},
		})
	end,
}
