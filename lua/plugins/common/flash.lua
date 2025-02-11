return {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    -- stylua: ignore
    keys = {
        {
            "s",
            mode = {"n", "x", "o"},
            function()
                require("flash").jump()
            end,
            desc = "Flash"
        },
        {
            "S",
            mode = {"n", "o", "x"},
            function()
                require("flash").treesitter()
            end,
            desc = "Flash Treesitter"
        }
    },
    config = function()
        require("flash").setup(
            {
                label = {
                    -- allow uppercase labels
                    uppercase = false,
                    rainbow = {
                        enabled = true,
                        -- number between 1 and 9
                        shade = 5
                    }
                }
            }
        )
    end
}
