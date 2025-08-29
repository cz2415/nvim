return {
	"shortcuts/no-neck-pain.nvim",
	version = "*",
	config = function()
		require("no-neck-pain").setup({
			width = 130,
			autocmds = {
				-- When `true`, entering one of no-neck-pain side buffer will automatically skip it and go to the next available buffer.
				skipEnteringNoNeckPainBuffer = true,
			},
		})
	end,
}
