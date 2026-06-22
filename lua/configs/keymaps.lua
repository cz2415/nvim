-- space as leader
vim.g.mapleader = " "
vim.g.maplocalleader = ";"

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local functions = require("configs.functions")

-- standard stlye cut/copy/paste
map("v", "<C-c>", '"+y', opts)
map("v", "<C-x>", '"+c<Esc>', opts)
map("i", "<C-v>", "<C-r><C-o>+", opts)

-- keep visual selection when (de)indenting
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- use <c-c> to exit terminal-mode
map("t", "<A-c>", [[<C-\><C-n>]], opts)

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
map("n", "<A-L>", ":vertical resize +1<CR>", opts)
map("n", "<A-H>", ":vertical resize -1<CR>", opts)

-- toggle wrap
map("n", "<A-z>", ":set wrap!<CR>", opts)

-- go to last change
map("n", "ga", "`.", opts)

vim.keymap.set("n", "gf", function()
	functions.smart_gf()
end, { desc = "Smart gf" })

local wk = require("which-key")

wk.add({
	{
		"==",
		'<cmd>:lua require("conform").format {async = true, lsp_fallback = true}<cr>',
		desc = "Format",
		mode = { "n", "v" },
	},
	{ "zn", "<cmd>NoNeckPain<cr>", desc = "Toggle neck mode", mode = "n" },
	{
		"zm",
		function()
			functions.toggle_maximize()
		end,
		desc = "Toggle neck mode",
		mode = "n",
	},
	{ "<leader>o", "<cmd>lua Snacks.picker.lsp_symbols()<cr>", desc = "Outline" },
	-- AI
	{ "<leader>a", group = "AI" },
	{ "<leader>ac", "<cmd>CodeCompanionChat<cr>", desc = "Start a chat session" },
	-- buffer
	{ "t", group = "Buffer" },
	{ "tC", "<cmd>BufferLineCloseOthers<cr>", desc = "Close Others" },
	{ "tt", "<cmd>lua Snacks.picker.buffers({ nofile = true })<cr>", desc = "Switch Buffer" },
	{ "tc", "<cmd>bd<cr>", desc = "Close Buffer" },
	{ "th", "<cmd>BufferLineMovePrev<cr>", desc = "Move Prev" },
	{ "tj", "<cmd>BufferLineCloseLeft<cr>", desc = "Close Left" },
	{ "tk", "<cmd>BufferLineCloseRight<cr>", desc = "Close Right" },
	{ "tl", "<cmd>BufferLineMoveNext<cr>", desc = "Move Next" },
	{ "tp", "<cmd>BufferLinePick<cr>", desc = "Buffer Pick" },
	-- file
	{ "<leader>f", group = "File" },
	{ "<leader>fT", "<cmd>lua Snacks.explorer.reveal()<cr>", desc = "Find In Tree" },
	{ "<leader>ff", "<cmd>lua Snacks.picker.files()<cr>", desc = "Find File" },
	{ "<leader>fg", "<cmd>lua Snacks.picker.grep()<cr>", desc = "Live Grep" },
	{
		"<leader>fg",
		function()
			functions.live_grep_visual_selection()
		end,
		desc = "Live Grep Selection",
		mode = "v",
	},
	{ "<leader>fh", "<cmd>lua Snacks.picker.help()<cr>", desc = "Help Tags" },
	{ "<leader>fn", "<cmd>enew<cr>", desc = "New File" },
	{ "<leader>fr", "<cmd>lua Snacks.picker.recent()<cr>", desc = "Recent Files" },
	{ "<leader>ft", "<cmd>lua Snacks.explorer.open()<cr>", desc = "Toggle File Tree" },
	{ "<leader>fm", "<cmd>lua MiniFiles.open()<cr>", desc = "Mini Files" },
	{ "<leader>fM", "<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<cr>", desc = "Mini Files Find" },
	-- quit
	{ "<leader>q", group = "Quit" },
	{ "<leader>qq", "<cmd>qall<cr>", desc = "Quit All" },
	{ "<leader>qr", "<cmd>restart<cr>", desc = "Restart" },
	-- session
	{ "<leader>p", group = "Session" },
	{
		"<leader>ps",
		function()
			require("mini.sessions").select()
		end,
		desc = "Select Session",
	},
	{
		"<leader>pw",
		function()
			local name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t"):gsub("[\\/:]", "_")
			require("mini.sessions").write(name, { force = true })
		end,
		desc = "Write Session",
	},
	{
		"<leader>pd",
		function()
			require("mini.sessions").select("delete")
		end,
		desc = "Delete Session",
	},
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
	-- terminal
	{ "<c-t>", group = "Terminal", mode = { "n", "t" } },
	{
		"<c-t>t",
		function()
			functions.toggle_snacks_terminal()
		end,
		desc = "Toggle Term",
		mode = { "n", "t" },
	},
	{
		"<c-t>n",
		function()
			functions.new_snacks_terminal()
		end,
		desc = "New Term",
		mode = { "n", "t" },
	},
	{
		"<c-t>s",
		function()
			functions.pick_snacks_terminal()
		end,
		desc = "Select Term",
		mode = { "n", "t" },
	},
	{
		"<c-t>r",
		function()
			functions.rename_snacks_terminal()
		end,
		desc = "Rename Term",
		mode = { "n", "t" },
	},
	{
		"<c-t>d",
		function()
			functions.delete_current_snacks_terminal()
		end,
		desc = "Delete Term",
		mode = { "n", "t" },
	},
	{
		"<c-t>1",
		function()
			functions.toggle_snacks_terminal(1)
		end,
		desc = "1st Term",
		mode = { "n", "t" },
	},
	{
		"<c-t>2",
		function()
			functions.toggle_snacks_terminal(2)
		end,
		desc = "2nd Term",
		mode = { "n", "t" },
	},
	{
		"<c-t>3",
		function()
			functions.toggle_snacks_terminal(3)
		end,
		desc = "3rd Term",
		mode = { "n", "t" },
	},
	{
		"<c-t>4",
		function()
			functions.toggle_snacks_terminal(4)
		end,
		desc = "4th Term",
		mode = { "n", "t" },
	},
	{
		"<c-t>5",
		function()
			functions.toggle_snacks_terminal(5)
		end,
		desc = "5th Term",
		mode = { "n", "t" },
	},
	{
		"<c-g>",
		function()
			functions.open_snacks_lazygit()
		end,
		desc = "LazyGit",
		mode = { "n", "t" },
	},

	-- search
	{ "<leader>s", group = "Search" },
	{
		"<leader>s/",
		function()
			require("snacks").picker.lines({
				layout = {
					preset = "telescope",
					preview = true,
				},
			})
		end,
		desc = "search Current Buffer With Snacks",
	},
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
				"<leader>o",
				function()
					require("kulala").search()
				end,
				desc = "Outline",
				buffer = 0,
			},
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
				"<A-CR>",
				function()
					require("kulala").run()
				end,
				desc = "Send request",
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
		wk.add({ { "<A-CR>", "<cmd>JdbcRun<cr>", desc = "Jdbc Run", mode = { "n", "v", "i" }, buffer = 0 } })
	end,
})

-- close with q
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = {
		"help",
		"crunner",
		"dap-repl",
		"checkhealth",
		"qf",
		"grug-far",
		"AvanteInput",
		"JdbcResult",
		"JdbcRowDetail",
	},
	callback = function()
		wk.add({ { "q", "<cmd>bd<cr>", desc = "Close Buffer", buffer = 0 } })
	end,
})

-- lsp & dap key config
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf

		wk.add({

			{ "g", group = "go to " },
			{ "gd", "<cmd>lua Snacks.picker.lsp_definitions()<cr>", desc = "go to definition" },
			{ "gr", "<cmd>lua Snacks.picker.lsp_references()<cr>", desc = "go to references" },
			{ "gl", "<cmd>lua vim.diagnostic.open_float({ border = 'rounded' })<cr>", desc = "show error description" },
			{ "ge", "<cmd>lua vim.diagnostic.jump({ count = 1 })<cr>", desc = "go to next diagnostic" },
			{ "gE", "<cmd>lua vim.diagnostic.jump({ count = -1 })<cr>", desc = "go to prev diagnostic" },
			{ "gs", "<cmd>lua Snacks.picker.diagnostics()<cr>", desc = "go to diagnostic list" },

			{ "<leader>c", group = "code" },
			{ "<leader>cc", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "code action" },
			{ "<leader>cr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "rename" },

			{ "<leader>d", group = "debug" },
			{ "<leader>dt", "<cmd>lua require('dap').toggle_breakpoint()<cr>", desc = "toggle breakpoint" },
			{ "<leader>du", "<cmd>lua require('dap'); require('dapui').toggle()<cr>", desc = "toggle debug ui" },
			{ "<leader>de", "<cmd>lua require('dap'); require('dapui').eval()<cr>", desc = "eval expression" },

			{ "<C-k>", '<cmd>lua require("dap").continue()<cr>', desc = "Continue" },
			{ "<C-j>", '<cmd>lua require("dap").step_over()<cr>', desc = "Step Over" },
			{ "<C-l>", '<cmd>lua require("dap").step_into()<cr>', desc = "Step Into" },
			{ "<C-h>", '<cmd>lua require("dap").step_out()<cr>', desc = "Step Out" },
		}, { buffer = bufnr })
	end,
})
