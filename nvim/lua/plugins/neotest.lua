return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-python",
    },
    -- Adapters are declared as `["module.name"] = config` so other specs (e.g.
    -- the LazyVim rust extra, which adds `rustaceanvim.neotest`) can merge
    -- their own adapters in. The config function below resolves them.
    opts = {
        adapters = {
            ["neotest-python"] = { runner = "pytest" },
        },
    },
    keys = {
        {
            "<leader>tr",
            function()
                require("neotest").run.run()
            end,
            desc = "Run nearest test",
        },
        {
            "<leader>tf",
            function()
                require("neotest").run.run(vim.fn.expand("%"))
            end,
            desc = "Run file tests",
        },
        {
            "<leader>ts",
            function()
                require("neotest").summary.toggle()
            end,
            desc = "Test summary",
        },
        {
            "<leader>to",
            function()
                require("neotest").output_panel.toggle()
            end,
            desc = "Test output",
        },
        {
            "<leader>td",
            function()
                ---@diagnostic disable-next-line: missing-fields
                require("neotest").run.run({ strategy = "dap" })
            end,
            desc = "Debug nearest test",
        },
    },
    config = function(_, opts)
        local adapters = {}
        for name, config in pairs(opts.adapters or {}) do
            if config ~= false then
                local adapter = require(name)
                if type(config) == "table" and not vim.tbl_isempty(config) then
                    local meta = getmetatable(adapter)
                    if adapter.setup then
                        adapter.setup(config)
                    elseif adapter.adapter then
                        adapter.adapter(config)
                        adapter = adapter.adapter
                    elseif meta and meta.__call then
                        adapter = adapter(config)
                    else
                        error("Adapter " .. name .. " does not support setup")
                    end
                end
                adapters[#adapters + 1] = adapter
            end
        end
        opts.adapters = adapters

        ---@diagnostic disable-next-line: missing-fields
        require("neotest").setup(opts)
    end,
}
