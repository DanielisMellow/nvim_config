return {
    "mfussenegger/nvim-lint",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        local function buf_dir()
            local name = vim.api.nvim_buf_get_name(0)
            if name == "" then
                return vim.fn.getcwd()
            end
            return vim.fs.dirname(name)
        end

        lint.linters.ruff.args = {
            "check",
            "--output-format",
            "json",
            "--stdin-filename",
            function()
                return vim.api.nvim_buf_get_name(0)
            end,
            "-",
        }

        lint.linters.pylint.args = {
            "--output-format=json",
            "--from-stdin",
            function()
                return vim.api.nvim_buf_get_name(0)
            end,
        }

        lint.linters.ruff.cwd = buf_dir
        lint.linters.pylint.cwd = buf_dir

        lint.linters_by_ft = {
            python = { "ruff", "pylint" },
        }

        local lint_names = { "ruff", "pylint" }
        local function lint_namespaces()
            local nss = {}
            for _, name in ipairs(lint_names) do
                local ok, ns = pcall(lint.get_namespace, name)
                if ok and ns then
                    nss[#nss + 1] = ns
                end
            end
            return nss
        end

        local lint_enabled = false
        local function toggle_lint_diagnostics()
            lint_enabled = not lint_enabled
            local nss = lint_namespaces()
            if lint_enabled then
                vim.notify("Lint Diagnostics Enabled", vim.log.levels.INFO)
                for _, ns in ipairs(nss) do
                    vim.diagnostic.enable(true, { bufnr = 0, ns_id = ns })
                end
                lint.try_lint()
            else
                vim.notify("Lint Diagnostics Hidden", vim.log.levels.WARN)
                for _, ns in ipairs(nss) do
                    vim.diagnostic.enable(false, { bufnr = 0, ns_id = ns })
                    vim.diagnostic.reset(ns, 0)
                end
            end
        end

        vim.keymap.set(
            "n",
            "<leader>i",
            toggle_lint_diagnostics,
            { noremap = true, silent = true, desc = "Toggle lint diagnostics" }
        )
    end,
}
