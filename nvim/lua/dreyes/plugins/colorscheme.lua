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

-- return {
-- 	{
-- 		"olimorris/onedarkpro.nvim",
-- 		lazy = false,
-- 		priority = 1000,
-- 		config = function()
-- 			require("onedarkpro").setup({
--
-- 				options = { transparency = true, cursorline = false },
-- 			})
--
-- 			vim.cmd("colorscheme onedark_dark")
-- 		end,
-- 	},
-- }

return {
	{
		"zootedb0t/citruszest.nvim",
		lazy = false,
		priority = 1000,

		config = function()
			require("citruszest").setup({

				option = {

					transparent = true,
				},
				style = {
					Constant = { bg = "#000000", bold = true },
				},
			})
			vim.cmd.colorscheme("citruszest")
		end,
	},
}

-- return {
-- 	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
-- 	{
-- 		"baliestri/aura-theme",
-- 		lazy = false,
-- 		priority = 1000,
-- 		config = function(plugin)
-- 			vim.opt.rtp:append(plugin.dir .. "/packages/neovim")
-- 			vim.cmd([[colorscheme aura-dark]])
-- 		end,
-- 	},
-- }

--[[ return {
	{
		"dasupradyumna/midnight.nvim",
		lazy = false,
		priority = 1000,

		config = function()
			require("midnight").setup({
				bg = "#000000",
			})
			vim.cmd.colorscheme("midnight")
		end,
	},
} ]]
