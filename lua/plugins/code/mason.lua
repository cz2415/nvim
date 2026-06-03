return {
	{
		"neovim/nvim-lspconfig",
		lazy = false,
	},
	{
		"williamboman/mason.nvim",
		cmd = {
			"Mason",
			"MasonInstall",
			"MasonUninstall",
			"MasonUninstallAll",
			"MasonLog",
			"MasonUpdate",
		},
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			require("mason").setup({
				PATH = "prepend", -- "skip" seems to cause the spawning error
				ui = {
					icons = {
						package_installed = "√",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})

			require("mason-lspconfig").setup({
				automatic_enable = false,
			})
		end,
	},
}
