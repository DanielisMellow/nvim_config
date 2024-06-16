return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		-- virtual text for the debugger
		{
			"theHamsta/nvim-dap-virtual-text",
			opts = {},
		},
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end
		require("dapui").setup()
	end,
    -- stylua: ignore
	keys = {
		{
			"<leader>dlc",
			function()
				-- (Re-)reads launch.json if present
				if vim.fn.filereadable(".vscode/launch.json") then
					require("dap.ext.vscode").load_launchjs(nil, {
						["codelldb"] = { "c", "cpp" },
					})
				end
				require("dap").continue()
			end,
			desc = "DAP Continue",
		},
		{
			"<leader>dt",
			function()
				require("dap").terminate(nil, nil, function() end)
				require("dapui").close()
			end,
			desc = "Terminate",
		},

		{"<leader>dq",function() require("dapui").close() end, desc = "Terminate",},
        { "<leader>B", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
        { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
        { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
        { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
        { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
        { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
},
}
