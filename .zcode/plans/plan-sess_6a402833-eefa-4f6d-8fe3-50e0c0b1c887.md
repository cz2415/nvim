修复 markdown 中 Tab 无法接受 codeium 建议的问题

## 根因
- codeium.vim 在全局插入模式映射 `<Tab>` → `codeium#Accept()`(接受灰色建议)。
- mkdnflow.nvim(`lua/plugins/note/mkdnflow.lua`,纯默认配置)在 markdown buffer 中创建 **buffer-local** 插入模式映射 `<Tab>` → `MkdnTableNextCell`、`<S-Tab>` → `MkdnTablePrevCell`。
- buffer-local 映射优先级高于全局映射,因此 md 文件里 Tab 被表格跳格抢占;光标不在表格中时无任何动作 —— 即"没反应"。

## 修改
只改一个文件 `lua/plugins/note/mkdnflow.lua`,在 setup 中禁用这两个插入模式映射:

```lua
return {
	"jakewvincent/mkdnflow.nvim",
	ft = "markdown",
	config = function()
		require("mkdnflow").setup({
			mappings = {
				MkdnTableNextCell = false,
				MkdnTablePrevCell = false,
			},
		})
	end,
}
```

- normal 模式的表格跳转/链接跳转不受影响(你已有 `<C-l>` → `:MkdnTab`、`<C-h>` → `:MkdnSTab` 映射)。
- 其他文件类型不受影响。

## 验证
1. 重启 nvim(或重新打开 md buffer),打开任意 md 文件进入插入模式。
2. 执行 `:verbose imap <Tab>`,应显示全局的 `codeium#Accept`,不再是 MkdnTableNextCell。
3. 触发 codeium 灰色建议后按 Tab,应能正常接受。