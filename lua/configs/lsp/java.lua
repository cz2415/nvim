local common = require("configs.lsp.common")

vim.lsp.config("jdtls", {
	on_attach = function(client, bufnr)
		common.on_attach(client, bufnr)

		local function java_run()
			local filename = vim.fn.expand("%:t:r")
			local dir = vim.fn.expand("%:p:h")
			vim.cmd("split | terminal cd " .. vim.fn.shellescape(dir) .. "; java " .. vim.fn.shellescape(filename .. ".java"))
		end

		vim.keymap.set("n", "<leader>jr", java_run, { buffer = bufnr, desc = "Java Run File" })
	end,
	capabilities = common.capabilities,
	filetypes = { "java" },
})

vim.lsp.enable({ "jdtls" })
