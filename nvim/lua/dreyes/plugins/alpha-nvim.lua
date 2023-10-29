return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Set header
		dashboard.section.header.val = {
			[[                                                          ]],
			[[                                                     ___  ]],
			[[                                                  ,o88888 ]],
			[[                                               ,o8888888' ]],
			[[                         ,:o:o:oooo.        ,8O88Pd8888"  ]],
			[[                     ,.::.::o:ooooOoOoO. ,oO8O8Pd888'"    ]],
			[[                   ,.:.::o:ooOoOoOO8O8OOo.8OOPd8O8O"      ]],
			[[                  , ..:.::o:ooOoOOOO8OOOOo.FdO8O8"        ]],
			[[                 , ..:.::o:ooOoOO8O888O8O,COCOO"          ]],
			[[                , . ..:.::o:ooOoOOOO8OOOOCOCO"            ]],
			[[                 . ..:.::o:ooOoOoOO8O8OCCCC"o             ]],
			[[                    . ..:.::o:ooooOoCoCCC"o:o             ]],
			[[                    . ..:.::o:o:,cooooCo"oo:o:            ]],
			[[                 `   . . ..:.:cocoooo"'o:o:::'            ]],
			[[                 .`   . ..::ccccoc"'o:o:o:::'             ]],
			[[                :.:.    ,c:cccc"':.:.:.:.:.'              ]],
			[[              ..:.:"'`::::c:"'..:.:.:.:.:.'               ]],
			[[            ...:.'.:.::::"'    . . . . .'                 ]],
			[[           .. . ....:."' `   .  . . ''                    ]],
			[[         . . . ...."'                                     ]],
			[[         .. . ."'                                         ]],
			[[        .                                                 ]],
			[[                                                          ]],

			[[M"""""""`YM MM""""""""`M MMP"""""YMM M""MMMMM""M M""M M"""""`'"""`YM]],
			[[M  mmmm.  M MM  mmmmmmmM M' .mmm. `M M  MMMMM  M M  M M  mm.  mm.  M]],
			[[M  MMMMM  M M`      MMMM M  MMMMM  M M  MMMMP  M M  M M  MMM  MMM  M]],
			[[M  MMMMM  M MM  MMMMMMMM M  MMMMM  M M  MMMM' .M M  M M  MMM  MMM  M]],
			[[M  MMMMM  M MM  MMMMMMMM M. `MMM' .M M  MMP' .MM M  M M  MMM  MMM  M]],
			[[M  MMMMM  M MM        .M MMb     dMM M     .dMMM M  M M  MMM  MMM  M]],
			[[MMMMMMMMMMM MMMMMMMMMMMM MMMMMMMMMMM MMMMMMMMMMM MMMM MMMMMMMMMMMMMM]],
		}

		-- Set menu
		dashboard.section.buttons.val = {
			dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
			dashboard.button("SPC ee", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
			dashboard.button("SPC ff", "󰱼 > Find File", "<cmd>Telescope find_files<CR>"),
			dashboard.button("SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
			dashboard.button("r", "  > Recent", ":Telescope oldfiles<CR>"),
			dashboard.button("q", " > Quit NVIM", "<cmd>qa<CR>"),
		}

		-- Send config to alpha
		alpha.setup(dashboard.opts)

		-- Disable folding on alpha buffer
		vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
	end,
}
