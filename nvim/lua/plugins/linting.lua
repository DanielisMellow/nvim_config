return {
    "mfussenegger/nvim-lint",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" }, -- Loads linting on file read/new file
    config = function()
        local lint = require("lint")
        local lint_enabled = false
        -- Override command arguments for Ruff and Pylint
        lint.linters.ruff.args = {
            "check",
            "--config",
            ".lint/pyproject.toml",
            "--output-format",
            "json",
            "--stdin-filename",
            function()
                return vim.api.nvim_buf_get_name(0)
            end,
            "-",
        }

        lint.linters.pylint.args = {
            "--rcfile=.lint/pyproject.toml",
            "--output-format=json",
            "--from-stdin",
            function()
                return vim.api.nvim_buf_get_name(0)
            end,
        }
        lint.linters_by_ft = {
            python = { "ruff", "pylint" },
        }

        -- Function to toggle linting
        local function toggle_lint_diagnostics()
            lint_enabled = not lint_enabled
            if lint_enabled then
                vim.notify("Lint Diagnostics Enabled", vim.log.levels.INFO)
                vim.diagnostic.enable(true, { bufnr = 0 })
                lint.try_lint()
            else
                vim.notify("Lint Diagnostics Hidden", vim.log.levels.WARN)
                vim.diagnostic.enable(false, { bufnr = 0 })
            end
        end
        vim.keymap.set("n", "<leader>i", toggle_lint_diagnostics, { noremap = true, silent = true, desc = "Toggle lint diagnostics" })
    end,
}
