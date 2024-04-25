return {
	-- mason.nvim integration
	{
		"jay-babu/mason-nvim-dap.nvim",
		event = "VeryLazy",
		dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
		cmd = { "DapInstall", "DapUninstall" },
		ensure_installed = { "debugpy", "cpptools", "codelldb" },
		automatic_installation = false,
		opts = {

			handlers = {
				function(config)
					-- all sources with no handler get passed here

					-- Keep original functionality
					require("mason-nvim-dap").default_setup(config)
				end,
				python = function(config)
					config.adapters = {
						type = "executable",
						command = "/home/lizardking/.local/share/nvim/mason/bin/debugpy-adapter",
						-- The first three options are required by nvim-dap
					}
					require("mason-nvim-dap").default_setup(config) -- don't forget this!
				end,
				cppdbg = function(config)
					config.adapters = {
						id = "cppdbg",
						type = "executable",
						command = "/home/lizardking/.local/share/nvim/mason/bin/OpenDebugAD7",
					}
					require("mason-nvim-dap").default_setup(config) -- don't forget this!
				end,
			},
		},
	},
}
