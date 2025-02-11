return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup(
                {
                    override = {
                        norg = {
                            icon = "",
                            name = "Norg"
                        },
                        http = {
                            icon = "󰖟",
                            name = "Http"
                        }
                    }
                }
            )
        end
    },
    config = function()
        local function my_on_attach(bufnr)
            local api = require "nvim-tree.api"

            local function opts(desc)
                return {desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true}
            end

            -- default mappings
            api.config.mappings.default_on_attach(bufnr)

            -- custom mappings
            vim.keymap.set("n", "<C-t>", api.tree.change_root_to_parent, opts("Up"))
            vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
            vim.keymap.set("n", "s", api.node.open.vertical, opts("Open: Vertical Split"))
        end

        require("nvim-tree").setup {
            on_attach = my_on_attach,
            sync_root_with_cwd = true,
            respect_buf_cwd = true,
            update_focused_file = {
                enable = true,
                update_root = true
            }
        }
    end
}
