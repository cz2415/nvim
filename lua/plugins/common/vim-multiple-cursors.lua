return {
    "terryma/vim-multiple-cursors",
    event = "VeryLazy",
    init = function()
        vim.g.multi_cursor_use_default_mapping = 0
        vim.g.multi_cursor_start_word_key = "<A-n>"
        vim.g.multi_cursor_start_key = "g<A-n>"
        vim.g.multi_cursor_next_key = "<A-n>"
        vim.g.multi_cursor_prev_key = "<A-p>"
        vim.g.multi_cursor_skip_key = "<A-x>"
        vim.g.multi_cursor_quit_key = "<Esc>"
    end
}
