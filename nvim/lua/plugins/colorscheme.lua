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
