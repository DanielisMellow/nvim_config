return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-python",
    },
    keys = {
        { "<leader>tr", function() require("neotest").run.run() end, desc = "Run nearest test" },
        { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
        { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test summary" },
        { "<leader>to", function() require("neotest").output_panel.toggle() end, desc = "Test output" },
        { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test" },
    },
    opts = {
        adapters = {
            ["neotest-python"] = {
                runner = "pytest",
            },
        },
    },
}
