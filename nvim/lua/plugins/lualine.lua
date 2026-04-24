return {
    "nvim-lualine/lualine.nvim",
    opts = {
        options = {
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
            icons_enabled = true,
            theme = "citruszest",
        },
        sections = {
            lualine_x = {
                {
                    function()
                        local lazy_status = require("lazy.status") -- Import lazy.status
                        if lazy_status.has_updates() then
                            return lazy_status.updates()
                        end
                        return ""
                    end,
                    cond = require("lazy.status").has_updates,
                    padding = 1,
                    max_length = vim.o.columns * 2 / 3,
                },
                { "encoding" },
                { "fileformat" },
                { "filetype" },

                {
                    function()
                        local reg = vim.fn.reg_recording()
                        if reg ~= "" then
                            return "Recording @" .. reg
                        end
                        return ""
                    end,
                    cond = function()
                        return vim.fn.reg_recording() ~= ""
                    end,
                    color = { fg = "#ff9e64", gui = "bold" }, -- Highlight recording mode
                },
            },
            lualine_z = {},
        },
    },
}
