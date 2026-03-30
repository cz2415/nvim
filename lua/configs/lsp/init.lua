local lsp_files = {
	"lua",
	"js",
	"py",
	"md",
}

for _, file in ipairs(lsp_files) do
	require("configs.lsp." .. file)
end
