-- Find And Replace plugin for neovim
return {
    "MagicDuck/grug-far.nvim",
    event = "VeryLazy",
    config = function()
        require("grug-far").setup({})
    end
}
