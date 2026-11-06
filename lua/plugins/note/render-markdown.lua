return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    opts = {
        heading = {
            position = "inline",
            sign = false,
            icons = {"󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 "},
            backgrounds = {}
        },
        code = {
            sign = false,
            width = "block",
            left_pad = 2
        },
        pipe_table = {
            preset = "round"
        },
        bullet = {
            -- 序号/圆点用 moonfly 紫罗兰色（默认 RenderMarkdownBullet 链到 Normal，等于无色）
            highlight = "MoonflyViolet"
        },
        checkbox = {
            custom = {
                todo = {raw = "[-]", rendered = "⧖", highlight = "RenderMarkdownTodo", scope_highlight = nil}
            }
        }
    }
}
