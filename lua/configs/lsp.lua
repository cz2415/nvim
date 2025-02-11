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
        filetypes = {"python"}
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

local root_dir = nvim_lsp.util.root_pattern("pom.xml", "build.gradle", ".git")

nvim_lsp.jdtls.setup(
    {
        cmd = {
            "jdtls",
            "-data",
        },
        root_dir = root_dir,
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = {"java"},
        settings = {
            java = {
                configuration = {
                    runtimes = {
                        {name = "Java21", path = "D:\\software\\portable\\Java\\21\\bin\\java.exe"} -- 指定 JDK 路径
                    }
                }
            }
        }
    }
)
