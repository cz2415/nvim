return {
	"nvim-jdbc",
	dir = "D:\\chen\\code\\nvim-jdbc\\nvim-jdbc-lua",
	ft = "sql",
	config = function()
		require("nvim-jdbc").setup({
			log_timing = false,
			backend_jar = "D:\\chen\\code\\nvim-jdbc\\nvim-jdbc-java\\target\\nvim-jdbc-java-1.0-SNAPSHOT.jar",
			jdbc_url = "jdbc:dm://localhost:5236",
			username = "TEST",
			password_env = "NVIM_JDBC_PASSWORD",
			backend_port = 9003,
		})
	end,
}
