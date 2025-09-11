-- option
vim.opt.history = 1001
vim.opt.scrolloff = 3
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.nu = true
vim.opt.rnu = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmatch = true
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.hidden = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.autochdir = true
vim.opt.wildmode = "list:longest,full"
vim.opt.langmenu = en_US
vim.opt.wrap = false
vim.opt.laststatus = 3
vim.opt.cmdheight = 0

vim.opt.fileencodings = "utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1"
vim.opt.enc = "utf-8"
vim.opt.fencs = "utf-8,gbk,gb2312,gb18030"

-- fold code by treesitter
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldenable = false

-- use powershell7 as default terminal
local powershell_options = {
	shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell",
	shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
	shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
	shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
	shellquote = "",
	shellxquote = "",
}

for option, value in pairs(powershell_options) do
	vim.opt[option] = value
end
