local common = require("configs.lsp.common")

local java8_home = vim.env.NVIM_JAVA8_HOME or "D:\\software\\portable\\Java\\8"
local java21_home = vim.env.NVIM_JAVA21_HOME or "D:\\software\\portable\\Java\\21"
local is_windows = package.config:sub(1, 1) == "\\"

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
		local java_exec = is_windows and (java8_home .. "\\bin\\java.exe") or enriched_config.javaExec

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

local function java8_env()
	local bin = path_join(java8_home, "bin")
	local path_sep = is_windows and ";" or ":"
	return {
		JAVA_HOME = java8_home,
		PATH = bin .. path_sep .. (vim.env.PATH or ""),
	}
end

local java_run_job
local java_run_tab

local function stop_java_run()
	if java_run_job then
		vim.fn.jobstop(java_run_job)
		java_run_job = nil
	end
end

local function run_in_terminal(command, cwd)
	if java_run_tab and vim.api.nvim_tabpage_is_valid(java_run_tab) then
		vim.api.nvim_set_current_tabpage(java_run_tab)
	else
		vim.cmd("tabnew")
		java_run_tab = vim.api.nvim_get_current_tabpage()
	end

	local old_buffer = vim.api.nvim_get_current_buf()
	local buffer = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(0, buffer)
	vim.api.nvim_buf_set_name(buffer, "JavaRun:" .. vim.fn.fnamemodify(command[1], ":t"))
	if vim.api.nvim_buf_is_valid(old_buffer) and old_buffer ~= buffer then
		pcall(vim.api.nvim_buf_delete, old_buffer, { force = true })
	end

	stop_java_run()
	java_run_job = vim.fn.termopen(command, {
		cwd = cwd,
		env = java8_env(),
		on_exit = function()
			java_run_job = nil
		end,
	})
	vim.cmd("startinsert")
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

	run_in_terminal(command, root)
end

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
end

local function command(name)
	return function()
		vim.cmd(name)
	end
end

local function setup_keymaps(bufnr)
	local maps = {
		{ "<leader>jr", function() spring_boot_run(bufnr, false) end, "Run Spring Boot" },
		{ "<leader>jR", command("JavaRunnerRunMain"), "Run Main (nvim-java)" },
		{ "<leader>js", stop_java_run, "Stop Spring Boot" },
		{ "<leader>jS", command("JavaRunnerStopMain"), "Stop Main (nvim-java)" },
		{ "<leader>jl", command("JavaRunnerToggleLogs"), "Toggle Logs" },
		{ "<leader>jD", command("JavaDapConfig"), "Refresh DAP Config" },
		{ "<leader>jd5", attach_java_5005, "Attach 5005" },
		{ "<leader>jdR", function() spring_boot_run(bufnr, true, false) end, "Debug Spring Boot" },
		{ "<leader>jdW", function() spring_boot_run(bufnr, true, true) end, "Debug Spring Boot Wait" },
		{ "<leader>jp", command("JavaProfile"), "Profiles" },
		{ "<leader>jv", command("JavaSettingsChangeRuntime"), "Change Runtime" },
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

	local ok, wk = pcall(require, "which-key")
	if ok then
		wk.add({
			{ "<leader>j", group = "Java", buffer = bufnr },
			{ "<leader>jt", group = "Java Test", buffer = bufnr },
			{ "<leader>jd", group = "Java Debug", buffer = bufnr },
		})
	end
end

setup_nvim_java()

vim.lsp.config("jdtls", {
	on_attach = function(client, bufnr)
		common.on_attach(client, bufnr)
		setup_keymaps(bufnr)
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
		},
	},
})

vim.lsp.enable("jdtls")
