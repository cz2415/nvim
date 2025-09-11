-- space as leader
vim.g.mapleader = " "
vim.g.maplocalleader = ";"

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- standard stlye cut/copy/paste
map("v", "<C-c>", '"+y', opts)
map("v", "<C-x>", '"+c<Esc>', opts)
map("i", "<C-v>", "<C-r><C-o>+", opts)

-- keep visual selection when (de)indenting
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- use <Esc> to exit terminal-mode
map("t", "<Esc>", [[<C-\><C-n>]], opts)

-- windows navigate, ALT+{h,j,k,l}
map("t", "<A-h>", [[<C-\><C-N><C-w>h]], opts)
map("t", "<A-j>", [[<C-\><C-N><C-w>j]], opts)
map("t", "<A-k>", [[<C-\><C-N><C-w>k]], opts)
map("t", "<A-l>", [[<C-\><C-N><C-w>l]], opts)
map("n", "<A-h>", [[<C-w>h]], opts)
map("n", "<A-j>", [[<C-w>j]], opts)
map("n", "<A-k>", [[<C-w>k]], opts)
map("n", "<A-l>", [[<C-w>l]], opts)

-- resize window
map("n", "<A-J>", ":resize -1<CR>", opts)
map("n", "<A-K>", ":resize +1<CR>", opts)
map("n", "<A-H>", ":vertical resize -1<CR>", opts)
map("n", "<A-L>", ":vertical resize +1<CR>", opts)

map("n", "<A-z>", ":set wrap!<CR>", opts)

-- go to last change
map("n", "ga", "`.", opts)

local wk = require("which-key")

wk.add({
	{
		"==",
		'<cmd>:lua require("conform").format {async = true, lsp_fallback = true}<cr>',
		desc = "Format",
		mode = "n",
	},
	{ "zn", "<cmd>NoNeckPain<cr>", desc = "Toggle neck mode", mode = "n" },
	{ "<leader>o", "<cmd>Navbuddy<cr>", desc = "Outline" },
	-- buffer
	{ "<leader>a", group = "AI" },
	{ "<leader>aa", "<cmd>AvanteAsk<cr>", desc = "Ask AI about your code", mode = "v" },
	{ "<leader>ae", "<cmd>AvanteEdit<cr>", desc = "Edit the selected code blocks", mode = "v" },
	{ "<leader>ac", "<cmd>AvanteChat<cr>", desc = "Start a chat session" },
	{ "<leader>af", "<cmd>AvanteFocus<cr>", desc = "Switch focus to/from the sidebar" },
	{ "<leader>ar", "<cmd>AvanteRefresh<cr>", desc = "Refresh all Avante windows" },
	{ "<leader>at", "<cmd>AvanteToggle<cr>", desc = "Toggle the Avante sidebar" },
	-- buffer
	{ "<leader>b", group = "Buffer" },
	{ "<leader>bC", "<cmd>BufferLineCloseOthers<cr>", desc = "Close Others" },
	{ "<leader>bb", "<cmd>Telescope buffers<CR>", desc = "Switch Buffer" },
	{ "<leader>bc", "<cmd>bd<cr>", desc = "Close Buffer" },
	{ "<leader>bh", "<cmd>BufferLineMovePrev<cr>", desc = "Move Prev" },
	{ "<leader>bj", "<cmd>BufferLineCloseLeft<cr>", desc = "Close Left" },
	{ "<leader>bk", "<cmd>BufferLineCloseRight<cr>", desc = "Close Right" },
	{ "<leader>bl", "<cmd>BufferLineMoveNext<cr>", desc = "Move Next" },
	{ "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Buffer Pick" },
	-- file
	{ "<leader>f", group = "File" },
	{ "<leader>fT", "<cmd>NvimTreeFindFile<cr>", desc = "Find In Tree" },
	{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File" },
	{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
	{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
	{ "<leader>fn", "<cmd>enew<cr>", desc = "New File" },
	{ "<leader>fp", "<cmd>NeovimProjectDiscover<cr>", desc = "Switch Project" },
	{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
	{ "<leader>ft", "<cmd>NvimTreeToggle<cr>", desc = "Toggle File Tree" },
	{ "<leader>fm", "<cmd>lua MiniFiles.open()<cr>", desc = "Mini Files" },
	{ "<leader>fM", "<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<cr>", desc = "Mini Files Find" },
	-- quit
	{ "<leader>q", group = "Quit" },
	{ "<leader>qq", "<cmd>qall<cr>", desc = "Quit All" },
	-- run
	{ "<leader>r", group = "Run Code" },
	{
		"<leader>rC",
		function()
			require("dap").continue()
		end,
		desc = "Debug Code",
	},
	{ "<leader>rc", "<cmd>RunCode<cr>", desc = "Run Current" },
	{ "<c-t>", group = "Terminal" },
	{ "<c-t>t", "<cmd>ToggleTerm<cr>", desc = "Toggle Term" },
	{ "<c-t>s", "<cmd>TermSelect<cr>", desc = "Select Term" },
	{ "<c-t>r", "<cmd>ToggleTermSetName<cr>", desc = "Rename Term" },
	{ "<c-t>g", "<cmd>ToggletermGitui<cr>", desc = "gitui" },
	{ "<c-t>1", "<cmd>1ToggleTerm<cr>", desc = "1st Term" },
	{ "<c-t>2", "<cmd>2ToggleTerm<cr>", desc = "2st Term" },
	{ "<c-t>3", "<cmd>3ToggleTerm<cr>", desc = "3st Term" },
	{ "<c-t>4", "<cmd>4ToggleTerm<cr>", desc = "4st Term" },
	{ "<c-t>5", "<cmd>5ToggleTerm<cr>", desc = "5st Term" },
	-- search
	{ "<leader>s", group = "Search" },
	{ "<leader>sc", "<cmd>set nohlsearch!<cr>", desc = "No Hlsearch" },
	{
		"<leader>sf",
		"<cmd>lua require('grug-far').open({ prefills = { paths = vim.fn.expand('%') } })<cr>",
		desc = "Search Current Buffer",
	},
	{
		"<leader>sp",
		"<cmd>lua require('grug-far').open({ prefills = { paths = vim.fn.getcwd() } })<cr>",
		desc = "Search Project",
	},
})

-- for http
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = "http, rest",
	callback = function()
		wk.add({
			-- {"<Localleader>r", group = "Rest"},
			{
				"<Localleader>b",
				function()
					require("kulala").scratchpad()
				end,
				desc = "Open scratchpad",
				buffer = 0,
			},
			{
				"<Localleader>o",
				function()
					require("kulala").open()
				end,
				desc = "Open kulala",
				buffer = 0,
			},
			{
				"<Localleader>t",
				function()
					require("kulala").toggle_view()
				end,
				desc = "Toggle headers/body",
				buffer = 0,
			},
			{
				"<Localleader>S",
				function()
					require("kulala").show_stats()
				end,
				desc = "Show stats",
				buffer = 0,
			},
			{
				"<Localleader>q",
				function()
					require("kulala").close()
				end,
				desc = "Close window",
				buffer = 0,
			},
			{
				"<Localleader>c",
				function()
					require("kulala").copy()
				end,
				desc = "Copy as cURL",
				buffer = 0,
			},
			{
				"<Localleader>C",
				function()
					require("kulala").from_curl()
				end,
				desc = "Paste from curl",
				buffer = 0,
			},
			{
				"<Localleader>s",
				function()
					require("kulala").run()
				end,
				desc = "Send request",
				buffer = 0,
			},
			{
				"<Localleader>a",
				function()
					require("kulala").run_all()
				end,
				desc = "Send all requests",
				buffer = 0,
			},
			{
				"<Localleader>i",
				function()
					require("kulala").inspect()
				end,
				desc = "Inspect current request",
				buffer = 0,
			},
			{
				"<Localleader>r",
				function()
					require("kulala").replay()
				end,
				desc = "Replay the last request",
				buffer = 0,
			},
			{
				"<Localleader>f",
				function()
					require("kulala").search()
				end,
				desc = "Find request",
				buffer = 0,
			},
			{
				"<Localleader>n",
				function()
					require("kulala").jump_next()
				end,
				desc = "Jump to next request",
				buffer = 0,
			},
			{
				"<Localleader>p",
				function()
					require("kulala").jump_prev()
				end,
				desc = "Jump to previous request",
				buffer = 0,
			},
			{
				"<Localleader>e",
				function()
					require("kulala").set_selected_env()
				end,
				desc = "Select environment",
				buffer = 0,
			},
			{
				"<Localleader>u",
				function()
					require("lua.kulala.ui.auth_manager").open_auth_config()
				end,
				desc = "Manage Auth Config",
				buffer = 0,
			},
			{
				"<Localleader>g",
				function()
					require("kulala").download_graphql_schema()
				end,
				desc = "Download GraphQL schema",
				buffer = 0,
			},
			{
				"<Localleader>x",
				function()
					require("kulala").scripts_clear_global()
				end,
				desc = "Clear globals",
				buffer = 0,
			},
			{
				"<Localleader>X",
				function()
					require("kulala").clear_cached_files()
				end,
				desc = "Clear cached files",
				buffer = 0,
			},
		})
	end,
})

-- for markdown
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = "markdown",
	callback = function()
		map("n", "<C-l>", ":MkdnTab<cr>", opts)
		map("n", "<C-h>", ":MkdnSTab<cr>", opts)
		wk.add({
			-- table
			{ "<Localleader>T", group = "Table" },
			{ "<Localleader>Tc", ":MkdnTable", desc = "Create Table", buffer = 0 },
			{ "<Localleader>Tf", "<cmd>MkdnTableFormat<cr>", desc = "Table Format", buffer = 0 },
			{ "<Localleader>Ti", "<cmd>MkdnTableNewColBefore<cr>", desc = "New Col Before", buffer = 0 },
			{ "<Localleader>Ta", "<cmd>MkdnTableNewColAfter<cr>", desc = "New Col After", buffer = 0 },
			{ "<Localleader>To", "<cmd>MkdnTableNewRowBelow<cr>", desc = "New Row Below", buffer = 0 },
			{ "<Localleader>TO", "<cmd>MkdnTableNewRowAbove<cr>", desc = "New Row Above", buffer = 0 },
			-- preview
			{ "<Localleader>p", group = "Preview" },
			{ "<Localleader>pp", "<cmd>MarkdownPreview<cr>", desc = "Markdown Preview Start", buffer = 0 },
			{ "<Localleader>ps", "<cmd>MarkdownPreviewStop<cr>", desc = "Markdown Preview Stop", buffer = 0 },
			{ "<Localleader>pt", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview Toggle", buffer = 0 },
			-- todo
			{ "<Localleader>t", group = "Todo" },
			{
				"<Localleader>ta",
				"<cmd>Checkmate archive<CR>",
				desc = "Archive checked/completed todo items (move to bottom section)",
				buffer = 0,
			},
			{ "<Localleader>tc", "<cmd>Checkmate check<CR>", desc = "Set todo item as checked (done)", buffer = 0 },
			{ "<Localleader>tn", "<cmd>Checkmate create<CR>", desc = "Create todo item", buffer = 0 },
			{
				"<Localleader>tR",
				"<cmd>Checkmate remove_all_metadata<CR>",
				desc = "Remove all metadata from a todo item",
				buffer = 0,
			},
			{ "<Localleader>tt", "<cmd>Checkmate toggle<CR>", desc = "Toggle todo item", buffer = 0 },
			{
				"<Localleader>tu",
				"<cmd>Checkmate uncheck<CR>",
				desc = "Set todo item as unchecked (not done)",
				buffer = 0,
			},
			{
				"<Localleader>tv",
				"<cmd>Checkmate metadata select_value<CR>",
				desc = "Update the value of a metadata tag under the cursor",
				buffer = 0,
			},
			{
				"<Localleader>t=",
				"<cmd>Checkmate cycle_next<CR>",
				desc = "Cycle todo item(s) to the next state",
				buffer = 0,
			},
			{
				"<Localleader>t-",
				"<cmd>Checkmate cycle_previous<CR>",
				desc = "Cycle todo item(s) to the previous state",
				buffer = 0,
			},
			{
				"<Localleader>t]",
				"<cmd>Checkmate metadata jump_next<CR>",
				desc = "Move cursor to next metadata tag",
				buffer = 0,
			},
			{
				"<Localleader>t[",
				"<cmd>Checkmate metadata jump_previous<CR>",
				desc = "Move cursor to previous metadata tag",
				buffer = 0,
			},
			{
				"<Localleader>td",
				function()
					require("checkmate").toggle_metadata("done")
				end,
				desc = "Toggle '@done' metadata",
				buffer = 0,
			},
			{
				"<Localleader>tp",
				function()
					require("checkmate").toggle_metadata("priority")
				end,
				desc = "Toggle '@priority' metadata",
				buffer = 0,
			},
			{
				"<Localleader>ts",
				function()
					require("checkmate").toggle_metadata("started")
				end,
				desc = "Toggle '@started' metadata",
				buffer = 0,
			},
			-- other
			{ "<Localleader>d", "<cmd>MkdnToggleToDo<cr>", desc = "Toggle ToDo", buffer = 0 },
			{ "<Localleader>n", "<cmd>MkdnUpdateNumbering<cr>", desc = "Update Number", buffer = 0 },
			{ "<cr>", "<cmd>MkdnNewListItem<cr>", desc = "New ListItem", mode = "i", buffer = 0 },
		})
	end,
})

-- for emmet
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = "javascriptreact,vue,html",
	callback = function()
		wk.add({ { "<C-k>", "<Plug>(emmet-expand-abbr)", desc = "emmet expand", mode = "i" } })
	end,
})

-- for sql
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = "sql",
	callback = function()
		wk.add({ { "[13;5u", "<cmd>JdbcRun<cr>", desc = "Jdbc Run", mode = { "n", "i" }, buffer = 0 } })
	end,
})

-- close with q
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = { "help", "crunner", "dap-repl", "checkhealth", "qf", "grug-far", "AvanteInput", "JdbcResult" },
	callback = function()
		wk.add({ { "q", "<cmd>bd<cr>", desc = "Close Buffer", buffer = 0 } })
	end,
})

-- lsp & dap key config
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf

		-- 支持的文件类型
		local filetypes = {
			"typescript",
			"typescriptreact",
			"typescript.tsx",
			"javascriptreact",
			"javascript",
			"python",
			"lua",
			"java",
			"vue",
		}

		-- 检查文件类型
		local ft = vim.bo[bufnr].filetype
		if not vim.tbl_contains(filetypes, ft) then
			return
		end

		-- 设置快捷键
		wk.add({
			{ "g", group = "go to " },
			{ "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "go to definition" },
			{ "ge", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "go to next diagnostic" },
			{ "gE", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "go to prev diagnostic" },
			{ "<leader>c", group = "code" },
			{ "<leader>cc", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "code action" },
			{ "<leader>cr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "rename" },

			{ "<leader>d", group = "debug" },
			{
				"<leader>dt",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "toggle breakpoint",
			},
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
				desc = "Toggle DAP UI",
			},
			{
				"<leader>de",
				function()
					require("dapui").eval()
				end,
				desc = "Eval expression",
			},

			{ "<C-k>", '<cmd>lua require("dap").continue()<cr>', desc = "Continue" },
			{ "<C-j>", '<cmd>lua require("dap").step_over()<cr>', desc = "Step Over" },
			{ "<C-l>", '<cmd>lua require("dap").step_into()<cr>', desc = "Step Into" },
			{ "<C-h>", '<cmd>lua require("dap").step_out()<cr>', desc = "Step Out" },
		}, { buffer = bufnr })
	end,
})
