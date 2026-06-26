return {
	"olimorris/codecompanion.nvim",
	cmd = {
		"CodeCompanion",
		"CodeCompanionActions",
		"CodeCompanionChat",
		"CodeCompanionCmd",
		"CodeCompanionCLI",
	},
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
			prompt_library = {
				["Explain code"] = {
					interaction = "chat",
					description = "Explain the selected code or current buffer",
					opts = { alias = "explain_code", auto_submit = true },
					prompts = {
						{
							role = "user",
							content = "请解释这段代码的意图、执行流程、关键依赖和可能的风险。回答要简洁，优先结合当前上下文。",
						},
					},
				},
				["Review code"] = {
					interaction = "chat",
					description = "Review code for bugs and maintainability issues",
					opts = { alias = "review_code", auto_submit = true },
					prompts = {
						{
							role = "user",
							content = "请以 code review 的方式检查这段代码。优先指出 bug、边界条件、可维护性问题和缺失测试。按严重程度排序，给出具体修改建议。",
						},
					},
				},
				["Fix code"] = {
					interaction = "inline",
					description = "Fix bugs in the selected code inline",
					opts = { alias = "fix_code" },
					prompts = {
						{
							role = "user",
							content = "修复这段代码中明显的 bug、异常路径和不合理实现。保持现有风格，尽量只改必要内容。只输出修改后的代码。",
						},
					},
				},
				["Refactor code"] = {
					interaction = "inline",
					description = "Refactor the selected code inline",
					opts = { alias = "refactor_code" },
					prompts = {
						{
							role = "user",
							content = "重构这段代码，提升可读性和可维护性，但不要改变外部行为。保持当前项目的编码风格。只输出修改后的代码。",
						},
					},
				},
				["Generate tests"] = {
					interaction = "inline",
					description = "Generate focused tests for the selected code",
					opts = { alias = "tests_code" },
					prompts = {
						{
							role = "user",
							content = "为这段代码生成有针对性的测试，覆盖正常路径、边界条件和失败路径。遵循当前项目已有测试风格。只输出测试代码。",
						},
					},
				},
				["Write docs"] = {
					interaction = "inline",
					description = "Write or improve documentation for code",
					opts = { alias = "docs_code" },
					prompts = {
						{
							role = "user",
							content = "为这段代码补充必要注释或文档。只在能帮助理解意图、约束或复杂逻辑时添加注释，避免解释显而易见的代码。只输出修改后的代码。",
						},
					},
				},
				["Commit message"] = {
					interaction = "chat",
					description = "Draft a concise git commit message",
					opts = { alias = "commit_msg", auto_submit = true },
					prompts = {
						{
							role = "user",
							content = "请根据当前变更生成一个简洁的 git commit message。优先使用 Conventional Commits 格式，并给出 1-3 条备选。",
						},
					},
				},
			},
			display = {
				action_palette = {
					opts = {
						show_preset_prompts = false,
					},
				},
			},
			opts = {
				log_level = "ERROR",
				language = "Chinese",
			},
		})
	end,
}
