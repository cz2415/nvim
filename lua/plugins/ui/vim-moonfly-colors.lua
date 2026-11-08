return {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    lazy = false,
    priority = 1000,
    config = function()
        vim.g.moonflyNormalFloat = true
        vim.g.moonflyTransparent = true
        vim.g.moonflyUnderlineMatchParen = true
        vim.g.moonflyVirtualTextColor = true
        vim.cmd([[colorscheme moonfly]])
        -- 分割线更醒目 (moonfly 默认太暗)
        vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#808080" })
    end
}
