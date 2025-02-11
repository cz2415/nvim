return {
    "akinsho/bufferline.nvim",
    vsersion = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    init = function()
        local opt = {noremap = true, silent = true}
        vim.api.nvim_set_keymap("n", "H", ":BufferLineCyclePrev<CR>", opt)
        vim.api.nvim_set_keymap("n", "L", ":BufferLineCycleNext<CR>", opt)
    end,
    config = function()
        require("bufferline").setup(
            {
                options = {
                    indicator = {
                        icon = "┃",
                        style = "icon"
                    },
                }
            }
        )
    end
}
