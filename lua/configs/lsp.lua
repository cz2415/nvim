local status, nvim_lsp = pcall(require, "lspconfig")
if not status then
	return
end

local on_attach = function(client, bufnr) end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local status_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if status_cmp then
	capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

vim.lsp.config("lua_ls", {
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "lua" },
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true, -- 只扫描 Neovim 核心 lua
					[vim.fn.expand("$HOME/.config/nvim/lua")] = true, -- 你自己的配置
				},
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

vim.lsp.config("ts_ls", {
	init_options = {
		plugins = {
			{
				name = "@vue/typescript-plugin",
				location = vim.fn.exepath("vue-language-server"),
				languages = { "vue" },
			},
		},
	},
	on_attach = on_attach,
	filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "html" },
})

vim.lsp.config("volar", {
	init_options = {
		vue = {
			hybridMode = false,
		},
	},
})

vim.lsp.config("eslint", {
	on_attach = on_attach,
	filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "html" },
})

vim.lsp.config("pylsp", {
	on_attach = on_attach,
	filetypes = { "python" },
	settings = {
		pylsp = {
			plugins = {
				mccabe = { enabled = false },
				pycodestyle = { enabled = false },
				pyflakes = { enabled = false },
			},
		},
	},
})

vim.lsp.config("html", {
	on_attach = on_attach,
	filetypes = { "html" },
})

vim.lsp.config("cssls", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
	on_attach = on_attach,
	filetypes = { "css" },
})

vim.lsp.config("marksman", {
	on_attach = on_attach,
	filetypes = { "markdown" },
})

vim.lsp.enable({ "lua_ls", "ts_ls", "volar", "eslint", "pylsp", "html", "cssls", "marksman" })

-- local root_dir = nvim_lsp.util.root_pattern("pom.xml", "build.gradle", ".git")
-- nvim_lsp.jdtls.setup(
--     {
--         cmd = {
--             "jdtls",
--             "-data",
--             "D:/chen/code/.jdtls/"
--         },
--         root_dir = root_dir,
--         on_attach = on_attach,
--         capabilities = capabilities,
--         filetypes = {"java"},
--         settings = {
--             java = {
--                 configuration = {
--                     runtimes = {
--                         {
--                             name = "JavaSE-21",
--                             path = "D:/software/portable/Java/21",
--                             default = true
--                         }
--                     }
--                 },
--                 maven = {
--                     userSettings = "D:/software/portable/apache-maven-3.6.3/conf/settings.xml"
--                 },
--                 implementationsCodeLens = {
--                     enabled = true -- 启用实现代码镜头
--                 },
--                 referencesCodeLens = {
--                     enabled = true -- 启用引用代码镜头
--                 }
--             }
--         },
--         init_options = {
--             bundles = {
--                 "D:/chen/code/tools/lombok.jar"
--             } -- 可添加 Lombok 等扩展包
--         }
--     }
-- )
