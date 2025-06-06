local status, nvim_lsp = pcall(require, "lspconfig")
if not status then
    return
end

local on_attach = function(client, bufnr)
    vim.keymap.set(
        {"i", "n", "v"},
        "<F5>",
        "<cmd>lua require'dap'.continue()<CR>",
        {silent = true, noremap = true, buffer = bufnr}
    )
    vim.keymap.set(
        {"i", "n", "v"},
        "<F10>",
        "<cmd>lua require'dap'.step_over()<CR>",
        {silent = true, noremap = true, buffer = bufnr}
    )
    vim.keymap.set(
        {"i", "n", "v"},
        "<F11>",
        "<cmd>lua require'dap'.step_into()<CR>",
        {silent = true, noremap = true, buffer = bufnr}
    )
    vim.keymap.set(
        {"i", "n", "v"},
        "<F12>",
        "<cmd>lua require'dap'.step_over()<CR>",
        {silent = true, noremap = true, buffer = bufnr}
    )
    vim.keymap.set(
        {"i", "n", "v"},
        "<F9>",
        "<cmd>lua require'dap'.toggle_breakpoint()<CR>",
        {silent = true, noremap = true, buffer = bufnr}
    )
end

nvim_lsp.lua_ls.setup(
    {
        on_attach = on_attach,
        filetypes = {"lua"},
        settings = {
            Lua = {
                diagnostics = {
                    globals = {"vim"}
                }
            }
        }
    }
)

nvim_lsp.ts_ls.setup(
    {
        init_options = {
            plugins = {
                {
                    name = "@vue/typescript-plugin",
                    location = require("mason-registry").get_package("vue-language-server"):get_install_path() ..
                        "/node_modules/@vue/language-server",
                    languages = {"vue"}
                }
            }
        },
        on_attach = on_attach,
        filetypes = {"typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "html"}
    }
)

nvim_lsp.volar.setup(
    {
        init_options = {
            vue = {
                hybridMode = false
            }
        }
    }
)

nvim_lsp.eslint.setup(
    {
        on_attach = on_attach,
        filetypes = {"typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "html"}
    }
)

nvim_lsp.pylsp.setup(
    {
        on_attach = on_attach,
        filetypes = {"python"},
        settings = {
            pylsp = {
                plugins = {
                    mccabe = {enabled = false},
                    pycodestyle = {enabled = false},
                    pyflakes = {enabled = false}
                }
            }
        }
    }
)

nvim_lsp.html.setup(
    {
        on_attach = on_attach,
        filetypes = {"html"}
    }
)

local capabilities = require("cmp_nvim_lsp").default_capabilities()
nvim_lsp.cssls.setup(
    {
        capabilities = capabilities,
        on_attach = on_attach,
        filetypes = {"css"}
    }
)

nvim_lsp.marksman.setup(
    {
        on_attach = on_attach,
        filetypes = {"markdown"}
    }
)

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
