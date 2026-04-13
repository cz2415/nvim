return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig"
    },
    config = function()
        require("mason").setup(
            {
                PATH = "prepend", -- "skip" seems to cause the spawning error
                ui = {
                    icons = {
                        package_installed = "√",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            }
        )

        require("mason-lspconfig").setup({
            automatic_enable = false
        })
    end
}
