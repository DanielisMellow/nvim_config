return {
	"VonHeikemen/lsp-zero.nvim",
	branch = "v2.x",
	dependencies = {
		-- LSP Support
		{ "williamboman/mason.nvim", build = ":MasonUpdate" }, -- Optional
		{ "williamboman/mason-lspconfig.nvim" }, -- Optional
		{ "neovim/nvim-lspconfig" }, -- Required
		{ "jayp0521/mason-null-ls.nvim" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "L3MON4D3/LuaSnip" },
	},
	config = function()
		local lsp = require("lsp-zero").preset({})

		lsp.ensure_installed({
			"lua_ls",
			"rust_analyzer",
			"clangd",
			"jedi_language_server", -- Python LSP
		})
		lsp.on_attach(function(client, bufnr)
			-- see :help lsp-zero-keybindings
			-- to learn the available actions
			lsp.default_keymaps({ buffer = bufnr })
		end)
		-- (Optional) Configure lua language server for neovim
		require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())
		lsp.setup()

		-- import mason-null-ls
		local mason_null_ls = require("mason-null-ls")
		mason_null_ls.setup({
			-- list of formatters & linters for mason to install
			ensure_installed = {
				"clang_format", -- C formatter
				"stylua", -- lua formatter
				"black", -- Python formatter
			},
			-- auto-install configured servers (with lspconfig)
			automatic_installation = true,
		})
	end,
}
