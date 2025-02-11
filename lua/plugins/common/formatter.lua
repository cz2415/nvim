return {
    "mhartington/formatter.nvim",
    event = "VeryLazy",
    config = function()
        -- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
        require("formatter").setup {
            filetype = {
                lua = {
                    function()
                        return {
                            exe = "luafmt",
                            args = {"--stdin"},
                            stdin = true
                        }
                    end
                },
                json = {
                    function()
                        local file = vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))
                        return {
                            exe = "prettier",
                            args = {file},
                            stdin = true
                        }
                    end
                },
                html = {
                    function()
                        local file = vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))
                        return {
                            exe = "prettier",
                            args = {file},
                            stdin = true
                        }
                    end
                },
                javascript = {
                    function()
                        local file = vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))
                        return {
                            exe = "prettier",
                            args = {file},
                            stdin = true
                        }
                    end
                },
                css = {
                    function()
                        local file = vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))
                        return {
                            exe = "prettier",
                            args = {file},
                            stdin = true
                        }
                    end
                },
                markdown = {
                    function()
                        local file = vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))
                        return {
                            exe = "prettier",
                            args = {file},
                            stdin = true
                        }
                    end
                },
                vue = {
                    function()
                        local file = vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))
                        return {
                            exe = "prettier",
                            args = {file},
                            stdin = true
                        }
                    end
                },
                ["*"] = {
                    require("formatter.filetypes.any").remove_trailing_whitespace
                }
            }
        }
    end
}
