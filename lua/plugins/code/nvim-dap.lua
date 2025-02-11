return {
    "mfussenegger/nvim-dap",
    dependencies = {
        {
            "rcarriga/nvim-dap-ui",
            config = function()
                require("dapui").setup()
                local dap, dapui = require("dap"), require("dapui")
                dap.listeners.after.event_initialized["dapui_config"] = function()
                    dapui.open({})
                end
                dap.listeners.before.event_terminated["dapui_config"] = function()
                    dapui.close({})
                end
                dap.listeners.before.event_exited["dapui_config"] = function()
                    dapui.close({})
                end
            end
        },
        "jay-babu/mason-nvim-dap.nvim",
        "nvim-neotest/nvim-nio",
        {
            "theHamsta/nvim-dap-virtual-text",
            config = function()
                require("nvim-dap-virtual-text").setup()
            end
        },
        "mxsdev/nvim-dap-vscode-js"
    },
    keys = {},
    config = function()
        -- break point config
        vim.api.nvim_set_hl(0, "DapBreakpoint", {ctermbg = 0, fg = "#993939", bg = "#31353f"})
        vim.api.nvim_set_hl(0, "DapLogPoint", {ctermbg = 0, fg = "#61afef", bg = "#31353f"})
        vim.api.nvim_set_hl(0, "DapStopped", {ctermbg = 0, fg = "#98c379", bg = "#31353f"})

        vim.fn.sign_define(
            "DapBreakpoint",
            {text = "•", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint"}
        )
        vim.fn.sign_define(
            "DapBreakpointCondition",
            {text = "?", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint"}
        )
        vim.fn.sign_define(
            "DapBreakpointRejected",
            {text = "×", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint"}
        )
        vim.fn.sign_define(
            "DapLogPoint",
            {text = "~", texthl = "DapLogPoint", linehl = "DapLogPoint", numhl = "DapLogPoint"}
        )
        vim.fn.sign_define(
            "DapStopped",
            {text = "›", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped"}
        )

        -- key
        -- 配置常见的 DAP 操作快捷键
        vim.api.nvim_set_keymap("n", "<C-k>", ':lua require("dap").continue()<CR>', {noremap = true, silent = true})
        vim.api.nvim_set_keymap("n", "<C-j>", ':lua require("dap").step_over()<CR>', {noremap = true, silent = true})
        vim.api.nvim_set_keymap("n", "<C-l>", ':lua require("dap").step_into()<CR>', {noremap = true, silent = true})
        vim.api.nvim_set_keymap("n", "<C-h>", ':lua require("dap").step_out()<CR>', {noremap = true, silent = true})
        vim.api.nvim_set_keymap(
            "n",
            "<leader>b",
            ':lua require("dap").toggle_breakpoint()<CR>',
            {noremap = true, silent = true}
        )
        vim.api.nvim_set_keymap(
            "n",
            "<leader>B",
            ':lua require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>',
            {noremap = true, silent = true}
        )
        vim.api.nvim_set_keymap(
            "n",
            "<leader>lp",
            ':lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>',
            {noremap = true, silent = true}
        )
        vim.api.nvim_set_keymap(
            "n",
            "<leader>dr",
            ':lua require("dap").repl.open()<CR>',
            {noremap = true, silent = true}
        )
        vim.api.nvim_set_keymap(
            "n",
            "<leader>dl",
            ':lua require("dap").run_last()<CR>',
            {noremap = true, silent = true}
        )

        require("dap").adapters["pwa-node"] = {
            type = "server",
            host = "localhost",
            port = "${port}",
            executable = {
                command = "D:\\software\\installer\\nvm\\v20.13.1\\node.exe",
                args = {
                    "C:\\Users\\cz2415\\AppData\\Local\\nvim-data\\mason\\packages\\js-debug-adapter\\js-debug\\src\\dapDebugServer.js",
                    "${port}"
                }
            }
        }

        require("dap").configurations.javascriptreact = {
            {
                type = "pwa-node",
                request = "launch",
                name = "Launch Program",
                program = "${file}",
                cwd = vim.fn.getcwd(),
                sourceMaps = true,
                protocol = "inspector",
                console = "integratedTerminal"
            }
        }

        require("dap").configurations.javascript = {
            {
                type = "pwa-node",
                request = "launch",
                name = "Launch Program",
                program = "${file}",
                cwd = vim.fn.getcwd(),
                sourceMaps = true,
                protocol = "inspector",
                console = "integratedTerminal"
            }
        }
    end
}
