return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		-- configure lualine with modified theme
		lualine.setup({
			options = {
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				icons_enable = true,
				theme = "citruszest",
			},
			sections = {
				lualine_x = {
					{
						mode = 0,
						lazy_status.updates,
						cond = lazy_status.has_updates,
						padding = 1,
						max_length = vim.o.columns * 2 / 3,
					},
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
				},
			},
		})
	end,
}
