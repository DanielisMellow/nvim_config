return {
	"rcarriga/nvim-dap-ui",
	event = "VeryLazy",
	dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	config = function()
		local dap = require("dap")
		vim.keymap.set("n", "<leader>B", dap.toggle_breakpoint, {})
		vim.keymap.set("n", "<leader>dc", dap.continue, {})
		vim.keymap.set("n", "<F10>", dap.step_over, {})
		vim.keymap.set("n", "<F11>", dap.step_into, {})
		vim.keymap.set("n", "<F12>", dap.step_out, {})

		local dapui = require("dapui")
		dap.adapters.cppdbg = {
			id = "cppdbg",
			type = "executable",
			command = "/home/lizardking/.vscode/extensions/ms-vscode.cpptools-1.20.1-linux-x64/debugAdapters/bin/OpenDebugAD7",
		}
		dap.configurations.c = {
			{
				name = "Launch file",
				type = "cppdbg",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopAtEntry = true,
			},
		}
		dap.configurations.cpp = dap.configurations.c

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
}
