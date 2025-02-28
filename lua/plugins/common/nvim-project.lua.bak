return {
    "coffebar/neovim-project",
    opts = {
        projects = {
            -- define project roots
            "C:/Users/cz2415/AppData/Local/nvim",
            "D:/chen/code/simple-admin/frontend/simple-admin",
            "D:/chen/code/simple-admin/backend/simple-admin",
            "D:/work/01.liming/02.code/lm-master",
            "D:/work/01.liming/02.code/bbom-app-lm",
            "D:/chen/obsidian"
        },
        picker = {
            type = "telescope"
        }
    },
    init = function()
        -- enable saving the state of plugins in the session
        vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
    end,
    dependencies = {
        {"nvim-lua/plenary.nvim"},
        -- optional picker
        {"nvim-telescope/telescope.nvim", tag = "0.1.4"},
        {"Shatur/neovim-session-manager"}
    },
    lazy = false,
    priority = 100
}
