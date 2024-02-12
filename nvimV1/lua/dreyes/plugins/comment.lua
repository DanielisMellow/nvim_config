return {
	"numToStr/Comment.nvim",
	config = function()
		require("Comment").setup()
	end,
}

-- _NORMAL_    'gcc' toggle comment a line
--             'gbc' toggles current line using blockwise comment
--             'gc[count]{motion} toggles region using linewise comment
