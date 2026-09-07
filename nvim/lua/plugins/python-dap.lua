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
                    -- Fall back to the interpreter uv resolves for this project
                    local uv_python = vim.fn.system("uv python find"):gsub("%s+", "")
                    if vim.v.shell_error == 0 and vim.fn.executable(uv_python) == 1 then
                        return uv_python
                    end
                end
                -- If all else fails, use the system Python
                return "python3"
            end

            dap_python.setup(get_python_path())
        end,
    },
}
