local common = require("configs.lsp.common")

local is_windows = package.config:sub(1, 1) == "\\"
local path_sep = is_windows and "\\" or "/"

-- 项目 JDK 大版本 -> 本机 JDK 路径, 可用 NVIM_JAVA{8,17,21}_HOME 覆盖
local jdk_homes = {
	[8] = vim.env.NVIM_JAVA8_HOME or "D:\\software\\portable\\Java\\8",
	[17] = vim.env.NVIM_JAVA17_HOME or "D:\\software\\portable\\Java\\17",
	[21] = vim.env.NVIM_JAVA21_HOME or "D:\\software\\portable\\Java\\21",
}

local java8_home = jdk_homes[8]
local java21_home = jdk_homes[21]

local function with_windows_system_path(callback)
	if not is_windows then
		return pcall(callback)
	end

	local original_path = vim.env.PATH
	vim.env.PATH = "C:\\Windows\\System32;" .. (original_path or "")
	local ok, err = pcall(callback)
	vim.env.PATH = original_path
	return ok, err
end

-- "1.8" -> 8, "17"/"21.0.1" -> 主版本号
local function parse_java_version(str)
	if not str then
		return nil
	end
	local major, minor = str:match("^(%d+)%.(%d+)")
	if major == "1" and minor then
		return tonumber(minor)
	end
	return tonumber(str:match("^(%d+)"))
end

-- 从 pom.xml / build.gradle 推断项目 JDK 大版本; 推断失败返回 nil
local java_version_patterns = {
	"<java%.version>%s*([%d%.]+)%s*</java%.version>",
	"<maven%.compiler%.release>%s*([%d%.]+)%s*<",
	"<maven%.compiler%.source>%s*([%d%.]+)%s*<",
}

local function detect_project_java_version(root)
	if not root then
		return nil
	end

	local pom = root .. path_sep .. "pom.xml"
	if vim.fn.filereadable(pom) == 1 then
		local content = table.concat(vim.fn.readfile(pom), "\n")
		for _, pattern in ipairs(java_version_patterns) do
			local version = parse_java_version(content:match(pattern))
			if version then
				return version
			end
		end
	end

	for _, name in ipairs({ "build.gradle", "build.gradle.kts" }) do
		local file = root .. path_sep .. name
		if vim.fn.filereadable(file) == 1 then
			local content = table.concat(vim.fn.readfile(file), "\n")
			local v = content:match("sourceCompatibility%s*=%s*[\"']?([%d%.]+)")
				or content:match("VERSION_(%d+)")
			local version = parse_java_version(v)
			if version then
				return version
			end
		end
	end

	return nil
end

-- 本机存在该版本 JDK 才返回路径, 否则 nil(回退系统 JAVA_HOME)
local function jdk_home_for(version)
	local home = version and jdk_homes[version] or nil
	if home and vim.fn.isdirectory(home) == 1 then
		return home
	end
	return nil
end

local function patch_nvim_java_runner()
	local ok, Runner = pcall(require, "java-runner.runner")
	if not ok or Runner._windows_classpath_patch then
		return
	end

	local run_ok, Run = pcall(require, "java-runner.run")
	local ui = require("java.ui.utils")
	local lsp_utils = require("java-core.utils.lsp")
	local profile_config = require("java.api.profile_config")
	local DapSetup = require("java-dap.setup")
	local classpath_sep = is_windows and ";" or ":"

	if run_ok then
		function Run:start(cmd)
			local normalized_cmd = {}
			for _, part in ipairs(cmd or {}) do
				if part and part ~= "" then
					table.insert(normalized_cmd, tostring(part))
				end
			end

			self.is_running = true
			self:send_term(table.concat(normalized_cmd, " ") .. "\n")

			self.job_chan_id = vim.fn.jobstart(normalized_cmd, {
				pty = true,
				on_stdout = function(_, data)
					self:send_term(data)
				end,
				on_exit = function(_, exit_code)
					self:on_job_exit(exit_code)
				end,
			})
		end
	end

	function Runner:select_dap_config(args)
		local dap = DapSetup(lsp_utils.get_jdtls())
		local dap_config_list = dap:get_dap_config()

		local selected_dap_config = ui.select("Select the main class (module -> mainClass)", dap_config_list, function(config)
			return config.name
		end)

		if not selected_dap_config then
			return nil, nil
		end

		local enriched_config = dap:enrich_config(selected_dap_config)

		local class_paths = table.concat(enriched_config.classPaths, classpath_sep)
		local main_class = enriched_config.mainClass
		local jdk_home = jdk_home_for(detect_project_java_version(project_root(0)))
		local java_exec = (is_windows and jdk_home and (jdk_home .. "\\bin\\java.exe")) or enriched_config.javaExec

		local active_profile = profile_config.get_active_profile(enriched_config.name)

		local vm_args = ""
		local prog_args = args

		if active_profile then
			prog_args = (active_profile.prog_args or "") .. " " .. (args or "")
			vm_args = active_profile.vm_args or ""
		end

		local cmd = {
			java_exec,
			vm_args,
			"-cp",
			class_paths,
			main_class,
			prog_args,
		}

		return cmd, selected_dap_config
	end

	Runner._windows_classpath_patch = true
end

local function path_join(...)
	return table.concat({ ... }, package.config:sub(1, 1))
end

local function first_readable(root, names)
	for _, name in ipairs(names) do
		local path = path_join(root, name)
		if vim.fn.filereadable(path) == 1 then
			return path
		end
	end
end

local function project_root(bufnr)
	local file = vim.api.nvim_buf_get_name(bufnr)
	return vim.fs.root(file, {
		"mvnw",
		"mvnw.cmd",
		"pom.xml",
		"gradlew",
		"gradlew.bat",
		"build.gradle",
		"build.gradle.kts",
		".git",
	}) or vim.fn.getcwd()
end

-- 按项目 JDK 版本构造运行环境; 本机没有对应 JDK 时返回 nil, 继承系统环境
local function jdk_env(version)
	local home = jdk_home_for(version)
	if not home then
		return nil
	end

	local bin = path_join(home, "bin")
	local env_path_sep = is_windows and ";" or ":"
	return {
		JAVA_HOME = home,
		PATH = bin .. env_path_sep .. (vim.env.PATH or ""),
	}
end

local java_run_job
local java_run_win
local java_run_buf
local java_run_root
local java_run_height = 15
local run_scrollback = 10000

local function stop_java_run()
	if java_run_job then
		vim.fn.jobstop(java_run_job)
		java_run_job = nil
	end
end

local function run_win_valid()
	return java_run_win and vim.api.nvim_win_is_valid(java_run_win)
end

-- 切换日志面板的软换行; 全局 <A-z> 只映射了 normal 模式, 面板聚焦时处于 terminal-mode 不生效
local function toggle_run_wrap()
	if not run_win_valid() then
		vim.notify("No Spring Boot run window yet", vim.log.levels.INFO)
		return
	end
	vim.wo[java_run_win].wrap = not vim.wo[java_run_win].wrap
end

-- 在底部 split 展示运行日志 buffer, 焦点保持在原窗口
local function show_run_buffer(buf)
	if run_win_valid() then
		if buf then
			vim.api.nvim_win_set_buf(java_run_win, buf)
		end
		return
	end

	local cur_win = vim.api.nvim_get_current_win()
	vim.cmd("botright " .. java_run_height .. "split")
	java_run_win = vim.api.nvim_get_current_win()
	if buf then
		vim.api.nvim_win_set_buf(java_run_win, buf)
		-- 日志滚到最新
		vim.api.nvim_win_call(java_run_win, function()
			vim.cmd("normal! G")
		end)
	end
	vim.api.nvim_set_current_win(cur_win)
end

-- 显示/隐藏底部运行日志面板
local function toggle_run_window()
	if run_win_valid() then
		vim.api.nvim_win_close(java_run_win, true)
		return
	end

	if not java_run_buf or not vim.api.nvim_buf_is_valid(java_run_buf) then
		vim.notify("No Spring Boot run buffer yet", vim.log.levels.INFO)
		return
	end

	show_run_buffer(java_run_buf)
end

-- terminal buffer「行可编辑但不可删除」, 只压 scrollback 清不掉可见屏幕区。
-- 实测有效的清屏: 缩窗到 1 行把旧行挤进 scrollback, scrollback=1 再挤掉, 之后恢复
local function clear_run_panel()
	if not (java_run_buf and vim.api.nvim_buf_is_valid(java_run_buf)) then
		vim.notify("No Spring Boot run buffer yet", vim.log.levels.INFO)
		return
	end

	-- 面板隐藏时先展开, 否则没有 window 参与 resize, 清不干净
	local focus_back
	if not run_win_valid() then
		focus_back = vim.api.nvim_get_current_win()
		show_run_buffer(java_run_buf)
	end
	if not run_win_valid() then
		return
	end

	local win = java_run_win
	local buf = java_run_buf
	local height = vim.api.nvim_win_get_height(win)

	vim.bo[buf].scrollback = 1
	vim.api.nvim_win_set_height(win, 1)

	vim.defer_fn(function()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_set_height(win, height)
		end
		if vim.api.nvim_buf_is_valid(buf) then
			vim.bo[buf].scrollback = run_scrollback
		end
		if run_win_valid() then
			vim.api.nvim_win_call(win, function()
				vim.cmd("normal! G")
			end)
		end
		if focus_back and vim.api.nvim_win_is_valid(focus_back) then
			vim.api.nvim_set_current_win(focus_back)
		end
	end, 200)
end

-- 在项目 src 下定位 class_name.java, 有 fqcn 时优先精确包路径匹配
local function find_java_file(root, fqcn, class_name)
	local search_dirs = {
		path_join(root, "src", "main", "java"),
		path_join(root, "src", "test", "java"),
		path_join(root, "target", "generated-sources"),
	}
	-- vim.fs.find 返回正斜杠路径, 后缀也用正斜杠比较
	local suffix = fqcn and (fqcn:gsub("%.", "/") .. "/" .. class_name .. ".java") or nil
	local fallback
	for _, dir in ipairs(search_dirs) do
		if vim.fn.isdirectory(dir) == 1 then
			for _, f in ipairs(vim.fs.find(class_name .. ".java", { path = dir, type = "file", limit = 20 })) do
				if suffix and f:sub(-#suffix) == suffix then
					return f
				end
				fallback = fallback or f
			end
		end
	end
	return fallback
end

-- IDEA 式堆栈跳转: 光标放堆栈行上回车, 跳到源码对应行
local function jump_to_stack_trace()
	local line = vim.api.nvim_get_current_line()
	local class_name, lnum = line:match("([%w$]+)%.java:(%d+)")
	if not class_name then
		vim.notify("No stack frame under cursor", vim.log.levels.INFO)
		return
	end

	-- "at com.x.Foo.bar(" -> 包路径 com.x (兼容内部类 com.x.Foo$1)
	local prefix = line:match("at ([%w%.$]+)%(") or line:match("([%w%.$]+)%(")
	local pkg = prefix and prefix:match("^(.*)%.[%w$]+$") or nil
	if pkg then
		pkg = pkg:gsub("%.[%w$]+$", "")
	end

	local root = java_run_root or project_root(0)
	local file = find_java_file(root, pkg, class_name)
	if not file then
		vim.notify(("Not found: %s.java in %s"):format(class_name, root), vim.log.levels.WARN)
		return
	end

	-- 面板在底部, 跳转发生在上一个 (代码) 窗口
	if run_win_valid() then
		vim.api.nvim_win_call(java_run_win, function()
			vim.cmd("wincmd p")
		end)
	end
	vim.cmd("edit " .. vim.fn.fnameescape(file))
	vim.api.nvim_win_set_cursor(0, { tonumber(lnum), 0 })
	vim.cmd("normal! zz")
end

-- 日志面板自己的按键: 面板是 terminal buffer, java buffer 的 <leader>j* 映射在这里不生效
local function map_run_buffer_keys(buf)
	local function set(modes, lhs, rhs, desc)
		vim.keymap.set(modes, lhs, rhs, { buffer = buf, silent = true, desc = desc })
	end
	set({ "n", "t" }, "<A-z>", toggle_run_wrap, "Toggle Wrap")
	set({ "n", "t" }, "<leader>jw", toggle_run_wrap, "Toggle Wrap")
	set({ "n", "t" }, "<C-l>", clear_run_panel, "Clear Run Panel")
	set({ "n", "t" }, "<CR>", jump_to_stack_trace, "Jump To Stack Trace")
	set({ "n", "t" }, "<leader>jj", toggle_run_window, "Toggle Run Panel")
	set({ "n", "t" }, "<leader>jc", clear_run_panel, "Clear Run Panel")
	set({ "n", "t" }, "<leader>js", stop_java_run, "Stop Spring Boot")
end

local function run_in_terminal(command, cwd, env)
	stop_java_run()
	java_run_root = cwd

	-- 清掉上一次已结束的运行 buffer
	if java_run_buf and vim.api.nvim_buf_is_valid(java_run_buf) then
		pcall(vim.api.nvim_buf_delete, java_run_buf, { force = true })
		java_run_buf = nil
	end

	local cur_win = vim.api.nvim_get_current_win()

	-- jobstart(term=true) 是 termopen 语义: 把「当前 buffer」整个变成终端。
	-- 必须先建专用 buffer 放进底部 split 并聚焦它, 否则会劫持代码 buffer
	java_run_buf = vim.api.nvim_create_buf(false, true)
	show_run_buffer(java_run_buf)
	if not run_win_valid() then
		return
	end
	vim.api.nvim_set_current_win(java_run_win)

	java_run_job = vim.fn.jobstart(command, {
		term = true,
		cwd = cwd,
		env = env,
		on_exit = function()
			java_run_job = nil
		end,
	})

	pcall(vim.api.nvim_buf_set_name, java_run_buf, "JavaRun:" .. vim.fn.fnamemodify(tostring(command[1]), ":t"))
	map_run_buffer_keys(java_run_buf)
	vim.api.nvim_win_call(java_run_win, function()
		vim.cmd("normal! G")
	end)

	-- 焦点回到代码窗口
	if vim.api.nvim_win_is_valid(cur_win) then
		vim.api.nvim_set_current_win(cur_win)
	end
end

local function spring_boot_command(root, debug, suspend)
	local mvn_wrapper = first_readable(root, is_windows and { "mvnw.cmd", "mvnw" } or { "mvnw", "mvnw.cmd" })
	local gradle_wrapper = first_readable(root, is_windows and { "gradlew.bat", "gradlew" } or { "gradlew", "gradlew.bat" })

	if mvn_wrapper or vim.fn.filereadable(path_join(root, "pom.xml")) == 1 then
		local command = { mvn_wrapper or "mvn", "spring-boot:run", "-Dspring-boot.run.profiles=local" }
		if debug then
			local suspend_flag = suspend and "y" or "n"
			table.insert(
				command,
				"-Dspring-boot.run.jvmArguments=-agentlib:jdwp=transport=dt_socket,server=y,suspend="
					.. suspend_flag
					.. ",address=5005"
			)
		end
		return command
	end

	if
		gradle_wrapper
		or vim.fn.filereadable(path_join(root, "build.gradle")) == 1
		or vim.fn.filereadable(path_join(root, "build.gradle.kts")) == 1
	then
		local command = { gradle_wrapper or "gradle", "bootRun", "--args=--spring.profiles.active=local" }
		if debug then
			table.insert(command, "--debug-jvm")
		end
		return command
	end
end

local function spring_boot_run(bufnr, debug, suspend)
	local root = project_root(bufnr)
	local command = spring_boot_command(root, debug, suspend)
	if not command then
		vim.notify("No Maven or Gradle Spring Boot project found", vim.log.levels.WARN)
		return
	end

	local version = detect_project_java_version(root)
	-- 强制 Spring 日志 ANSI 彩色 (应用 stdout 经 Maven fork 成管道, 自动检测会关掉颜色)
	local env = vim.tbl_extend("force", jdk_env(version) or {}, {
		SPRING_OUTPUT_ANSI_ENABLED = "always",
	})
	if version and not env then
		vim.notify(
			("Project targets Java %d but no matching local JDK, falling back to system JAVA_HOME"):format(version),
			vim.log.levels.WARN
		)
	end

	run_in_terminal(command, root, env)
end

-- ===== Run Anything (对标 IDEA double-Ctrl) =====
local run_history = {}
local maven_presets = {
	"clean package -DskipTests",
	"clean install -DskipTests",
	"test",
	"dependency:tree",
	"spring-boot:run",
}

local function maven_command(root, args_str)
	local parts = { first_readable(root, is_windows and { "mvnw.cmd" } or { "mvnw" }) or "mvn" }
	for word in args_str:gmatch("%S+") do
		parts[#parts + 1] = word
	end
	return parts
end

local function is_maven_input(input)
	local first = input:match("^(%S+)") or ""
	if input:match("^mvn[%s]") or input == "mvn" or input:match("^gradle[%s]") then
		return true
	end
	local maven_first = {
		clean = true, compile = true, test = true, package = true, install = true,
		verify = true, site = true, deploy = true, help = true,
	}
	return maven_first[first] or input:match("^[%w%-]+:[%w%-]+") ~= nil
end

local function run_anything()
	local root = java_run_root or project_root(0)
	java_run_root = root

	local function complete(arg)
		local cands = {}
		for _, h in ipairs(run_history) do
			cands[#cands + 1] = h
		end
		for _, p in ipairs(maven_presets) do
			cands[#cands + 1] = "mvn " .. p
		end
		local out = {}
		for _, c in ipairs(cands) do
			if arg == "" or c:find(arg, 1, true) then
				out[#out + 1] = c
			end
		end
		return out
	end

	vim.fn.inputsave()
	local input = vim.fn.input({ prompt = "Run Anything (Tab 补全): ", completion = complete, cancelreturn = "" })
	vim.fn.inputrestore()
	input = vim.trim(input or "")
	if input == "" then
		return
	end

	-- 历史去重置顶
	for i, h in ipairs(run_history) do
		if h == input then
			table.remove(run_history, i)
			break
		end
	end
	table.insert(run_history, 1, input)
	if #run_history > 20 then
		table.remove(run_history)
	end

	local cmd, env
	if is_maven_input(input) then
		cmd = maven_command(root, input:gsub("^mvn[%s]+", ""))
		env = vim.tbl_extend("force", jdk_env(detect_project_java_version(root)) or {}, {
			SPRING_OUTPUT_ANSI_ENABLED = "always",
		})
	else
		-- 任意 shell 命令, 走 cmd /c 保证内置命令与管道可用
		cmd = { "cmd", "/c", input }
	end

	run_in_terminal(cmd, root, env)
end

vim.keymap.set("n", "<C-Space>", run_anything, { desc = "Run Anything" })
vim.keymap.set("n", "<leader>rm", run_anything, { desc = "Run Anything (Maven/shell)" })

local function setup_java_attach_adapter()
	local dap = require("dap")
	if dap.adapters["java-attach"] then
		return
	end

	dap.adapters["java-attach"] = function(callback)
		local runner = require("async.runner")

		runner(function()
				local JavaDebug = require("java-core.ls.clients.java-debug-client")
				local lsp_utils = require("java-core.utils.lsp")
				local debug_client = JavaDebug(lsp_utils.get_jdtls())
				local port = debug_client:start_debug_session()

				callback({
					type = "server",
					host = "127.0.0.1",
					port = port,
				})
			end)
			.catch(function(err)
				vim.schedule(function()
					vim.notify("Java attach adapter failed: " .. tostring(err), vim.log.levels.ERROR)
				end)
			end)
			.run()
	end
end

local function attach_java_5005()
	setup_java_attach_adapter()
	require("dap").run({
		type = "java-attach",
		request = "attach",
		name = "Attach Java 5005",
		hostName = "127.0.0.1",
		port = 5005,
	})
end

local function setup_nvim_java()
	local ok, java = pcall(require, "java")
	if not ok then
		vim.notify("nvim-java is not installed yet. Run :Lazy sync, then restart Neovim.", vim.log.levels.WARN)
		return
	end

	patch_nvim_java_runner()

	local setup_ok, err = with_windows_system_path(function()
		java.setup({
			jdtls = {
				version = "1.54.0",
			},
			jdk = {
				auto_install = false,
			},
			lombok = {
				enable = true,
			},
			java_test = {
				enable = true,
			},
			java_debug_adapter = {
				enable = true,
			},
			spring_boot_tools = {
				enable = true,
			},
		})
	end)

	if not setup_ok then
		vim.notify("nvim-java setup failed: " .. tostring(err), vim.log.levels.ERROR)
	end
	return setup_ok
end

local function command(name)
	return function()
		vim.cmd(name)
	end
end

-- 跳转到 super 类/super 方法 (jdtls 的 workspace/executeCommand 导航命令)
local super_commands = {
	"java.action.navigateToSuperDefinition",
	"java.action.navigateToSuperImplementation",
}

local function jump_to_super_location(result, client)
	if type(result) == "table" and result[1] and not result.uri and not result.edit and not result.targetUri then
		result = result[1]
	end
	if type(result) ~= "table" then
		return false
	end

	local encoding = client.offset_encoding or "utf-16"
	if result.uri or result.targetUri then
		vim.lsp.util.jump_to_location({
			uri = result.uri or result.targetUri,
			range = result.range or result.targetRange,
		}, encoding)
		return true
	end
	if result.edit then
		vim.lsp.util.apply_workspace_edit(result.edit, encoding)
		return true
	end
	return false
end

local function goto_super()
	local bufnr = vim.api.nvim_get_current_buf()
	local client = vim.lsp.get_clients({ bufnr = bufnr, name = "jdtls" })[1]
	if not client then
		vim.notify("jdtls not attached", vim.log.levels.WARN)
		return
	end

	local arguments = {
		vim.uri_from_bufnr(bufnr),
		{ line = vim.fn.line(".") - 1, character = vim.fn.col(".") - 1 },
	}

	local function try(idx)
		if idx > #super_commands then
			vim.notify("No super definition under cursor", vim.log.levels.INFO)
			return
		end

		client:exec_cmd({
			command = super_commands[idx],
			arguments = arguments,
		}, bufnr, function(err, result)
			if err or not jump_to_super_location(result, client) then
				try(idx + 1)
			end
		end)
	end

	try(1)
end

local function setup_keymaps(bufnr)
	local maps = {
		{ "<leader>jr", function() spring_boot_run(bufnr, false) end, "Run Spring Boot" },
		{ "<leader>jR", command("JavaRunnerRunMain"), "Run Main (nvim-java)" },
		{ "<leader>js", stop_java_run, "Stop Spring Boot" },
		{ "<leader>jj", toggle_run_window, "Toggle Run Panel" },
		{ "<leader>jw", toggle_run_wrap, "Toggle Run Panel Wrap" },
		{ "<leader>jc", clear_run_panel, "Clear Run Panel" },
		{ "<leader>jS", command("JavaRunnerStopMain"), "Stop Main (nvim-java)" },
		{ "<leader>jl", command("JavaRunnerToggleLogs"), "Toggle Logs" },
		{ "<leader>jD", command("JavaDapConfig"), "Refresh DAP Config" },
		{ "<leader>jd5", attach_java_5005, "Attach 5005" },
		{ "<leader>jdR", function() spring_boot_run(bufnr, true, false) end, "Debug Spring Boot" },
		{ "<leader>jdW", function() spring_boot_run(bufnr, true, true) end, "Debug Spring Boot Wait" },
		{ "<leader>jp", command("JavaProfile"), "Profiles" },
		{ "<leader>jv", command("JavaSettingsChangeRuntime"), "Change Runtime" },
		{
			"<leader>ji",
			function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }))
			end,
			"Toggle Inlay Hints",
		},
		{ "<leader>jb", command("JavaBuildBuildWorkspace"), "Build Workspace" },
		{ "<leader>jB", command("JavaBuildCleanWorkspace"), "Clean Workspace" },
		{ "<leader>jtc", command("JavaTestRunCurrentClass"), "Test Class" },
		{ "<leader>jtm", command("JavaTestRunCurrentMethod"), "Test Method" },
		{ "<leader>jta", command("JavaTestRunAllTests"), "Test All" },
		{ "<leader>jdc", command("JavaTestDebugCurrentClass"), "Debug Test Class" },
		{ "<leader>jdm", command("JavaTestDebugCurrentMethod"), "Debug Test Method" },
		{ "<leader>jda", command("JavaTestDebugAllTests"), "Debug All Tests" },
		{ "<leader>jtr", command("JavaTestViewLastReport"), "Test Report" },
	}

	for _, map in ipairs(maps) do
		vim.keymap.set("n", map[1], map[2], { buffer = bufnr, desc = map[3] })
	end

	-- keymaps.lua 的 LspAttach 映射晚于 on_attach 生效, 延迟注册保证 gi/gs 在 java buffer 优先
	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end
		vim.keymap.set("n", "gi", function()
			require("snacks").picker.lsp_implementations()
		end, { buffer = bufnr, desc = "go to implementation" })
		vim.keymap.set("n", "gs", goto_super, { buffer = bufnr, desc = "go to super" })
	end)

	local ok, wk = pcall(require, "which-key")
	if ok then
		wk.add({
			{ "<leader>j", group = "Java", buffer = bufnr },
			{ "<leader>jt", group = "Java Test", buffer = bufnr },
			{ "<leader>jd", group = "Java Debug", buffer = bufnr },
		})
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	once = true,
	callback = function(args)
		local setup_ok = setup_nvim_java()

		vim.lsp.config("jdtls", {
			on_attach = function(client, bufnr)
				common.on_attach(client, bufnr)
				setup_keymaps(bufnr)
				if client.server_capabilities.inlayHintProvider then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end
			end,
			capabilities = common.capabilities,
			filetypes = { "java" },
			settings = {
				java = {
					configuration = {
						runtimes = {
							{
								name = "JavaSE-1.8",
								path = java8_home,
								default = true,
							},
							{
								name = "JavaSE-21",
								path = java21_home,
							},
						},
						updateBuildConfiguration = "interactive",
					},
					import = {
						gradle = {
							wrapper = {
								enabled = true,
							},
						},
					},
					maven = {
						downloadSources = true,
					},
					project = {
						importOnFirstTimeStartup = "automatic",
					},
					-- IDEA 式参数名内联提示 (none | literals | all)
					inlayHints = {
						parameterNames = {
							enabled = "all",
						},
					},
				},
			},
		})

		vim.lsp.enable("jdtls")

		-- spring-boot.nvim 的 LS 启动 autocmd 是在本 FileType 事件内注册的, 当前 buffer 错过触发;
		-- 重放一次让独立 spring-boot LS 立即启动, 否则 jdtls sts 扩展会报 Client not found: spring-boot
		if setup_ok and vim.api.nvim_buf_is_valid(args.buf) then
			pcall(vim.api.nvim_exec_autocmds, "FileType", { buffer = args.buf })
		end
	end,
})

-- 保存 java 文件时自动整理 import (IDEA 默认行为)
local function organize_imports(bufnr)
	local client = vim.lsp.get_clients({ bufnr = bufnr, name = "jdtls" })[1]
	if not client then
		return
	end
	local params = {
		textDocument = { uri = vim.uri_from_bufnr(bufnr) },
		range = { start = { line = 0, character = 0 }, ["end"] = { line = 0, character = 0 } },
		context = { only = { "source.organizeImports" }, diagnostics = {} },
	}
	local res = client:request_sync("textDocument/codeAction", params, 3000, bufnr)
	for _, action in ipairs(res and res.result or {}) do
		if action.kind and action.kind:find("source.organizeImports", 1, true) then
			if action.edit then
				vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
			end
			if type(action.command) == "table" then
				vim.lsp.buf.execute_command(action.command)
			end
			break
		end
	end
end

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "java",
	callback = function(args)
		organize_imports(args.buf)
	end,
})
