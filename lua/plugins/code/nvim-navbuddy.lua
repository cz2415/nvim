return {
    "SmiteshP/nvim-navbuddy",
    dependencies = {
        "SmiteshP/nvim-navic",
        "MunifTanjim/nui.nvim"
    },
    config = function()
        local actions = require("nvim-navbuddy.actions")
        require("nvim-navbuddy").setup(
            {
                lsp = {auto_attach = true},
                window = {
                    size = "80%"
                },
                mappings = {
                    ["t"] = actions.telescope(
                        {
                            layout_config = {
                                prompt_position = "bottom",
                            },
                            layout_strategy = "horizontal"
                        }
                    )
                }
            }
        )
    end
}
