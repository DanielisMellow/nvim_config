return {
    {
        "mfussenegger/nvim-dap-python",
        config = function()
            local dap_python = require("dap-python")
            local function get_python_path()
                local cwd = vim.fn.getcwd()
                -- Check for virtual environment in the project directory
                if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                    return cwd .. "/.venv/bin/python"
                elseif vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                    return cwd .. "/venv/bin/python"
                else
                    -- Fall back to pyenv's Python if available
                    local pyenv_python = vim.fn.system("pyenv which python"):gsub("%s+", "")
                    if vim.fn.executable(pyenv_python) == 1 then
                        return pyenv_python
                    end
                end
                -- If all else fails, use the system Python (or pyenv shim if configured)
                return "python3"
            end

            dap_python.setup(get_python_path())
        end,
    },
}
