return {
	"L3MON4D3/LuaSnip",
	branch = "master",
	dependencies = {
		"rafamadriz/friendly-snippets",
		"onsails/lspkind-nvim",
	},
	config = function()
		-- Adding JavaScript snippets in typescript files
		-- require("luasnip").filetype_extend("typescript", { "javascript", "jsx" })
		-- require("luasnip").setup({
		-- 	-- Other filetypes just load themselves. -- javascript for html. -- Also load both lua and json when a markdown-file is opened,
		-- 	load_ft_func = require("luasnip.extras.filetype_functions").extend_load_ft({
		-- 		markdown = { "lua", "json" },
		-- 		html = { "javascript" },
		-- 	}),
		-- })
	end,
}
