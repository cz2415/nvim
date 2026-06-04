return {
	{
		"nvim-mini/mini.animate",
		version = "*",
		opts = function()
			local mouse_scrolled = false
			for _, scroll in ipairs({ "Up", "Down" }) do
				local key = "<ScrollWheel" .. scroll .. ">"
				vim.keymap.set({ "", "i" }, key, function()
					mouse_scrolled = true
					return key
				end, { expr = true })
			end

			local animate = require("mini.animate")
			return {
				resize = {
					timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),
				},
				scroll = {
					timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
					subscroll = animate.gen_subscroll.equal({
						predicate = function(total_scroll)
							if mouse_scrolled then
								mouse_scrolled = false
								return false
							end
							return total_scroll > 1
						end,
					}),
				},
			}
		end,
	},
	{
		"nvim-mini/mini.files",
		event = "VeryLazy",
		version = "*",
		config = function()
			require("mini.files").setup({
				windows = {
					max_number = math.huge,
					preview = true,
					width_focus = 50,
					width_nofocus = 15,
					width_preview = 55,
				},
				mappings = {
					synchronize = "<C-s>",
				},
			})
		end,
	},
	{
		"nvim-mini/mini.align",
		version = "*",
		config = function()
			require("mini.align").setup()
		end,
	},
	{
		"nvim-mini/mini.sessions",
		version = "*",
		config = function()
			local sessions = require("mini.sessions")
			local session_dir = vim.fn.stdpath("data") .. "/session"

			-- 统一路径格式，避免 Windows 分隔符和盘符大小写影响比较。
			local normalize_path = function(path)
				if type(path) ~= "string" or path == "" then
					return nil
				end

				local ok, normalized = pcall(vim.fs.normalize, vim.fn.fnamemodify(path, ":p"))
				normalized = ok and normalized or path
				normalized = normalized:gsub("\\", "/"):gsub("/+$", "")

				if vim.fn.has("win32") == 1 then
					normalized = normalized:lower()
				end

				return normalized
			end

			-- session 文件里的 `cd ...` 记录了当时保存 session 的项目根目录。
			local read_session_cwd = function(path)
				if vim.fn.filereadable(path) ~= 1 then
					return nil
				end

				for _, line in ipairs(vim.fn.readfile(path, "", 40)) do
					local dir = line:match("^cd%s+(.+)$")
					if dir then
						return normalize_path(dir)
					end
				end
			end

			local path_contains = function(parent, child)
				if not parent or not child then
					return false
				end

				return child == parent or child:sub(1, #parent + 1) == parent .. "/"
			end

			-- 优先选择项目根目录包含当前 cwd 的 session。
			local get_cwd_session = function()
				local cwd = normalize_path(vim.fn.getcwd())
				local best_name, best_len

				for name, data in pairs(sessions.detected) do
					local root = read_session_cwd(data.path)
					if path_contains(root, cwd) and (not best_len or #root > best_len) then
						best_name, best_len = name, #root
					end
				end

				return best_name
			end

			-- 保持和 mini.sessions 原本 autoread 类似的保护逻辑，避免 `nvim file` 被 session 覆盖。
			local should_autoread = function()
				if vim.fn.argc() > 0 then
					return false
				end

				local listed_buffers = vim.tbl_filter(function(buf)
					return vim.fn.buflisted(buf) == 1
				end, vim.api.nvim_list_bufs())
				if #listed_buffers > 1 then
					return false
				end

				if vim.bo.filetype ~= "" then
					return false
				end

				if vim.api.nvim_buf_line_count(0) > 1 then
					return false
				end

				local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, true)[1] or ""
				return first_line == ""
			end

			sessions.setup({
				autoread = false,
				autowrite = true,
				directory = session_dir,
				file = "",
				force = { read = false, write = true, delete = true },
				hooks = {
					pre = {
						-- remove no-name buffers before write
						write = function()
							for _, buf in ipairs(vim.api.nvim_list_bufs()) do
								if vim.api.nvim_buf_get_name(buf) == "" then
									vim.api.nvim_buf_delete(buf, { force = true })
								end
							end
						end,
					},
					post = {
						-- remove no-name buffers after read
						read = function()
							for _, buf in ipairs(vim.api.nvim_list_bufs()) do
								if vim.api.nvim_buf_get_name(buf) == "" then
									vim.api.nvim_buf_delete(buf, { force = true })
								end
							end
						end,
					},
				},
			})

			vim.api.nvim_create_autocmd("VimEnter", {
				group = vim.api.nvim_create_augroup("MiniSessionsCwdAutoread", { clear = true }),
				nested = true,
				once = true,
				desc = "Autoread cwd session or latest session",
				callback = function()
					if not should_autoread() then
						return
					end

					local session_name = get_cwd_session() or sessions.get_latest()
					if session_name then
						sessions.read(session_name)
					end
				end,
			})
		end,
	},
}
