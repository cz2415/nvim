local function lazygit_edit_config()
	local server = vim.v.servername
	if server == nil or server == "" then
		return {
			editPreset = "",
			edit = 'nvim -- "{{filename}}"',
			editAtLine = 'nvim -- "+{{line}}" "{{filename}}"',
		}
	end

	server = server:gsub('"', '\\"')
	return {
		editPreset = "",
		edit = ('nvim --server "%s" --remote-send q && nvim --server "%s" --remote-tab "{{filename}}"'):format(
			server,
			server
		),
		editAtLine = ('nvim --server "%s" --remote-send q && nvim --server "%s" --remote-tab "+{{line}}" "{{filename}}"'):format(
			server,
			server
		),
	}
end

-- ===== snacks explorer: o 弹出文件操作菜单 =====
-- 文件管理器式的复制/剪切剪贴板 (会话内有效); 复制会同时写入 "+" 寄存器, 内置 p 也能粘贴
local ex_clip = { mode = nil, paths = {} }

-- 当前操作对象: 多选 (>tab 标记) 优先, 否则光标所在条目
local function ex_paths(picker)
	return vim.tbl_map(Snacks.picker.util.path, picker:selected({ fallback = true }))
end

local function ex_relpath(picker, path)
	local ok, rel = pcall(vim.fs.relpath, picker:cwd(), path)
	return (ok and rel) or vim.fn.fnamemodify(path, ":.")
end

local function ex_paste(picker)
	local ex = require("snacks.explorer.actions")
	local Tree = require("snacks.explorer.tree")
	local dir = picker:dir()

	if ex_clip.mode == "copy" then
		Snacks.picker.util.copy(ex_clip.paths, dir)
		Tree:refresh(dir)
		Tree:open(dir)
		ex.update(picker, { target = dir })
		Snacks.notify.info(("Pasted %d item(s) -> %s"):format(#ex_clip.paths, vim.fn.fnamemodify(dir, ":t")))
	elseif ex_clip.mode == "cut" then
		local moved, skipped = 0, 0
		for _, from in ipairs(ex_clip.paths) do
			local to = dir .. "/" .. vim.fn.fnamemodify(from, ":t")
			-- 移动到自身或自身子目录, 或目标重名时跳过
			if from == to or dir:sub(1, #from + 1) == from .. "/" then
				skipped = skipped + 1
			elseif (vim.uv or vim.loop).fs_stat(to) then
				skipped = skipped + 1
				Snacks.notify.warn("Already exists, skipped: " .. vim.fn.fnamemodify(to, ":t"))
			else
				Snacks.rename.rename_file({ from = from, to = to })
				Tree:refresh(vim.fs.dirname(from))
				moved = moved + 1
			end
		end
		Tree:refresh(dir)
		Tree:open(dir)
		ex.update(picker, { target = dir })
		ex_clip = { mode = nil, paths = {} } -- 剪切粘贴一次后清空
		Snacks.notify.info(("Moved %d item(s)%s"):format(moved, skipped > 0 and (", skipped " .. skipped) or ""))
	else
		-- 没有内部剪贴板内容时, 退回内置粘贴 (读 "+" 寄存器)
		picker:action("explorer_paste")
	end
end

-- 右键菜单样式浮窗: 跟随光标, CR/鼠标选择, Esc/q 关闭, 数字键直达
local function open_context_menu(entries)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"

	local lines = vim.tbl_map(function(e)
		return (" %d. %s"):format(e.idx, e.desc)
	end, entries)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- 序号用暗色 (Comment 高亮)
	for i, e in ipairs(entries) do
		vim.api.nvim_buf_set_extmark(buf, vim.api.nvim_create_namespace("ctx_menu"), i - 1, 1, {
			end_col = 1 + #tostring(e.idx) + 2,
			hl_group = "Comment",
		})
	end

	local width = 0
	for _, l in ipairs(lines) do
		width = math.max(width, vim.fn.strdisplaywidth(l))
	end
	width = width + 2

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "cursor",
		row = 1,
		col = 2,
		width = width,
		height = #entries,
		style = "minimal",
		border = "rounded",
		zindex = 200,
	})
	vim.wo[win].cursorline = true
	vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel"
	vim.api.nvim_win_set_cursor(win, { 1, 0 })

	local done = false
	local function close()
		if done then
			return
		end
		done = true
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end
	local function accept()
		if done then
			return
		end
		local l = vim.api.nvim_win_get_cursor(win)[1]
		close()
		local entry = entries[l]
		if entry then
			entry.fn()
		end
	end

	local opts = { buffer = buf, silent = true, nowait = true }
	vim.keymap.set("n", "<CR>", accept, opts)
	vim.keymap.set("n", "<Esc>", close, opts)
	vim.keymap.set("n", "q", close, opts)
	vim.keymap.set("n", "<LeftRelease>", function()
		local pos = vim.fn.getmousepos()
		if pos.winid == win and pos.line >= 1 and pos.line <= #entries then
			vim.api.nvim_win_set_cursor(win, { pos.line, 0 })
			accept()
		end
	end, opts)
	for i in ipairs(entries) do
		vim.keymap.set("n", tostring(i), function()
			vim.api.nvim_win_set_cursor(win, { i, 0 })
			accept()
		end, opts)
	end
	-- 焦点离开浮窗时自动收起 (如点击了其他窗口)
	vim.api.nvim_create_autocmd("WinLeave", {
		callback = function()
			if vim.api.nvim_get_current_win() == win then
				vim.schedule(close)
			end
		end,
		once = true,
	})
end

local function explorer_menu(picker, item)
	if not item then
		return
	end
	local ex = require("snacks.explorer.actions")

	local entries = {
		{ desc = "Open in file manager", fn = function() ex.actions.explorer_open(nil, item) end },
		{
			desc = "Copy",
			fn = function()
				ex_clip = { mode = "copy", paths = ex_paths(picker) }
				vim.fn.setreg("+", table.concat(ex_clip.paths, "\n"), "l")
				Snacks.notify.info("Copied " .. #ex_clip.paths .. " item(s), go to target dir: o -> Paste")
			end,
		},
		{
			desc = "Cut",
			fn = function()
				ex_clip = { mode = "cut", paths = ex_paths(picker) }
				Snacks.notify.info("Cut " .. #ex_clip.paths .. " item(s), go to target dir: o -> Paste")
			end,
		},
		{ desc = "Paste", fn = function() ex_paste(picker) end },
		{
			desc = "Copy filename",
			fn = function()
				local names = vim.tbl_map(function(p) return vim.fn.fnamemodify(p, ":t") end, ex_paths(picker))
				vim.fn.setreg("+", table.concat(names, "\n"), "l")
				Snacks.notify.info("Copied filename")
			end,
		},
		{
			desc = "Copy relative path",
			fn = function()
				local paths = vim.tbl_map(function(p) return ex_relpath(picker, p) end, ex_paths(picker))
				vim.fn.setreg("+", table.concat(paths, "\n"), "l")
				Snacks.notify.info("Copied relative path")
			end,
		},
		{
			desc = "Copy absolute path",
			fn = function()
				local paths = vim.tbl_map(function(p) return vim.fn.fnamemodify(p, ":p") end, ex_paths(picker))
				vim.fn.setreg("+", table.concat(paths, "\n"), "l")
				Snacks.notify.info("Copied absolute path")
			end,
		},
	}

	for i, e in ipairs(entries) do
		e.idx = i
	end
	open_context_menu(entries)
end

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		bufdelete = { enabled = true },
		explorer = { enabled = true },
		lazygit = {
			enabled = true,
			config = {
				os = lazygit_edit_config(),
			},
		},
		quickfile = { enabled = true },
		picker = {
			enabled = true,
			ui_select = true,
			layout = {
				preset = "telescope",
			},
			actions = {
				explorer_menu = explorer_menu,
			},
			sources = {
				explorer = {
					win = {
						list = {
							keys = {
								["o"] = { "explorer_menu", mode = { "n", "x" } },
							},
						},
					},
				},
			},
		},
		terminal = {
			enabled = true,
			win = {
				border = "rounded",
				position = "float",
			},
		},
	},
	keys = {},
	init = function() end,
}
