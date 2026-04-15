local lsp_files = {
	"lua",
	"js",
	"py",
	"md",
	"java",
}

for _, file in ipairs(lsp_files) do
	require("configs.lsp." .. file)
end
