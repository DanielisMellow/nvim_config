--[[ return{
  {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup()

    -- setup must be called before loading
    vim.cmd.colorscheme "catppuccin"
  end,
},
}

 ]]

--[[ return {
	{
		"gmr458/dark_modern.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("dark_modern").setup({
				cursorline = true,
				transparent_background = false,
				nvim_tree_darker = true,
			})
			vim.cmd.colorscheme("dark_modern")
		end,
	},
}
 ]]

return {
	{
		"olimorris/onedarkpro.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("onedarkpro").setup({

				options = { transparency = true, cursorline = false },
			})

			vim.cmd("colorscheme onedark_dark")
		end,
	},
}
