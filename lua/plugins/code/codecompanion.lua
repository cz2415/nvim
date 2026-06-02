return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("codecompanion").setup({
			adapters = {
				http = {
					deepseek = function()
						return require("codecompanion.adapters").extend("deepseek", {
							env = {
								api_key = "DEEPSEEK_API_KEY",
							},
							schema = {
								model = {
									default = "deepseek-v4-flash",
								},
							},
						})
					end,
				},
			},
			interactions = {
				opts = {
					date_format = "%Y-%m-%d",
				},
				chat = {
					adapter = {
						name = "deepseek",
						model = "deepseek-v4-flash",
					},
				},
				inline = {
					adapter = {
						name = "deepseek",
						model = "deepseek-v4-flash",
					},
				},
				cmd = {
					adapter = {
						name = "deepseek",
						model = "deepseek-v4-flash",
					},
				},
			},
			opts = {
				log_level = "ERROR",
			},
		})
	end,
}
