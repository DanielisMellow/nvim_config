return {

	"ThePrimeagen/harpoon",
	config = function()
		local mark = require("harpoon.mark")
		local ui = require("harpoon.ui")

		vim.keymap.set("n", "<a-a>", mark.add_file)
		vim.keymap.set("n", "<a-0>", ui.toggle_quick_menu)
		-- Harpoon marked files 1 through 4
		vim.keymap.set("n", "<a-1>", function()
			ui.nav_file(1)
		end)
		vim.keymap.set("n", "<a-2>", function()
			ui.nav_file(2)
		end)
		vim.keymap.set("n", "<a-3>", function()
			ui.nav_file(3)
		end)
		vim.keymap.set("n", "<a-4>", function()
			ui.nav_file(4)
		end)
		-- Harpoon next and prev files
		vim.keymap.set("n", "<a-5>", function()
			ui.nav_next()
		end)
		vim.keymap.set("n", "<a-6>", function()
			ui.nav_prev()
		end)
	end,
}
