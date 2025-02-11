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
        checkbox = {
            custom = {
                todo = {raw = "[-]", rendered = "⧖", highlight = "RenderMarkdownTodo", scope_highlight = nil}
            }
        }
    }
}
