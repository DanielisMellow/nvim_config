-- lua/config/autocmds.lua
-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

----------------------------------------------------------------------
-- Run current Python file macro (@g)
----------------------------------------------------------------------

vim.api.nvim_create_augroup("run_file", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
    group = "run_file",
    pattern = "*.py",
    callback = function()
        local py = vim.g.python3_host_prog or "python3"
        -- CHANGE: Use \r instead of <CR>
        -- We use [[ ]] string for cleaner syntax, but "..." works too
        local cmd = (":w\r:vsp | terminal %s %% \r"):format(py)
        vim.fn.setreg("g", cmd)
    end,
})

----------------------------------------------------------------------
-- Autoformat toggles per filetype
----------------------------------------------------------------------

local set_autoformat = function(pattern, enabled)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = pattern,
        callback = function()
            vim.b.autoformat = enabled
        end,
    })
end

-- Preferences
set_autoformat({ "python" }, false)
set_autoformat({ "lua" }, true)
