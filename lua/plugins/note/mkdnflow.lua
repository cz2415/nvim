return {
	"jakewvincent/mkdnflow.nvim",
	ft = "markdown",
	config = function()
		require("mkdnflow").setup({
			mappings = {
				MkdnTableNextCell = false,
				MkdnTablePrevCell = false,
			},
		})
	end,
}
