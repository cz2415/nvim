return {
	"brenoprata10/nvim-highlight-colors",
	ft = { "css", "scss", "vue", "html", "typescript" },
	config = function()
		require("nvim-highlight-colors").setup({})
	end,
}
