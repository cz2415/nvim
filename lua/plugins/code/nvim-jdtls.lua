return {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
        local jdtls = require("jdtls")

        -- jdtls 配置
        local conf = {
            cmd = {"~/AppData/Local/nvim-data/mason/bin/jdtls.cmd"},
            root_dir = vim.fs.dirname(vim.fs.find({"gradlew", ".git", "mvnw", "pom.xml"}, {upward = true})[1])
        }

        jdtls.start_or_attach(conf)
    end
}
