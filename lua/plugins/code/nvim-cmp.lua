return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        {
            "neovim/nvim-lspconfig",
            dependencies = {
                {
                    "SmiteshP/nvim-navbuddy",
                    dependencies = {
                        "SmiteshP/nvim-navic",
                        "MunifTanjim/nui.nvim"
                    },
                    opts = {lsp = {auto_attach = true}}
                }
            }
        },
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "saadparwaiz1/cmp_luasnip"
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        cmp.setup(
            {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end
                },
                sources = {
                    {name = "path"},
                    {name = "buffer"},
                    {name = "nvim_lsp"},
                    {name = "luasnip"}
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered()
                },
                formatting = {
                    fields = {"menu", "abbr", "kind"},
                    format = function(entry, item)
                        local menu_icon = {
                            path = "🖫",
                            buffer = "Ω",
                            nvim_lsp = "λ",
                            luasnip = "⋗"
                        }
                        item.menu = menu_icon[entry.source.name]
                        return item
                    end
                },
                mapping = cmp.mapping.preset.insert(
                    {
                        ["<C-e>"] = cmp.mapping.abort(),
                        ["<CR>"] = cmp.mapping.confirm({select = false})
                    }
                )
            }
        )

        -- Set configuration for specific filetype.
        cmp.setup.filetype(
            "gitcommit",
            {
                sources = cmp.config.sources(
                    {
                        {name = "git"} -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
                    },
                    {
                        {name = "buffer"}
                    }
                )
            }
        )

        -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(
            {"/", "?"},
            {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    {name = "buffer"}
                }
            }
        )

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(
            ":",
            {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources(
                    {
                        {name = "path"}
                    },
                    {
                        {name = "cmdline"}
                    }
                ),
                matching = {disallow_symbol_nonprefix_matching = false}
            }
        )

        require("luasnip.loaders.from_vscode").lazy_load()
    end
}
