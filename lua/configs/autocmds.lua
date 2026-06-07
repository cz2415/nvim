-- hight light yank
vim.api.nvim_create_autocmd({ "textyankpost" }, {
	pattern = { "*" },
	callback = function()
		vim.highlight.on_yank({
			timeout = 300,
		})
	end,
})

-- auto save
vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
	callback = function()
		vim.fn.execute("silent! write")
	end,
})

-- son fold
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = "json",
	callback = function()
		vim.fn.execute("silent! set foldmethod=indent")
	end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = "markdown",
	callback = function()
		vim.fn.execute("silent! set foldmethod=manual")
	end,
})

-- for emmet
-- vim.api.nvim_create_autocmd(
--     {"FileType"},
--     {
--         pattern = "javascript",
--         callback = function()
--             vim.fn.execute("silent! set filetype=jsx")
--         end
--     }
-- )

-- Later, or in another file, when you create keymaps for LSP
-- vim.api.nvim_create_autocmd("LspAttach", {
-- 	callback = function(ev)
-- 		local keymap_opts = { remap = false, silent = true, buffer = ev.buf }
-- 		vim.keymap.set("n", "<Esc>", function()
-- 			CloseAllFloating()
-- 		end, keymap_opts)
-- 	end,
-- })

-- for work root
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		local file = vim.api.nvim_buf_get_name(0)
		if file == "" then
			return
		end

		local root = vim.fs.find({
			".svn",
			".git",
			"package.json",
			"pom.xml",
			"obsidian.iml",
		}, {
			path = file,
			upward = true,
		})[1]

		if root then
			local dir = vim.fs.dirname(root)
			if vim.fn.getcwd() ~= dir then
				vim.cmd("lcd " .. dir)
			end
		end
	end,
})
