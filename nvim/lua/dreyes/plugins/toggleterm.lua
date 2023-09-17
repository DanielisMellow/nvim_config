return {
	"akinsho/toggleterm.nvim",

	config = function()
		require("toggleterm").setup({
			size = 80,
			insert_mappings = false,
			open_mapping = [[\\]],
			autochdir = true,
			start_in_insert = true,
			direction = "vertical",
			auto_scroll = true,
		})
	end,
}
