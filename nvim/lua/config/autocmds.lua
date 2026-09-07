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
        -- Run through uv so the script uses the project's env (pyproject/.venv)
        -- rather than the Neovim provider interpreter. \r triggers the command.
        vim.fn.setreg("g", ":w\r:vsp | terminal uv run python %% \r")
    end,
})

----------------------------------------------------------------------
-- Run current Rust crate macro (@g)
----------------------------------------------------------------------
-- Same muscle memory as the Python macro above, but Rust builds a crate
-- rather than a file, so this is `cargo run` from the project root.

vim.api.nvim_create_augroup("run_crate", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
    group = "run_crate",
    pattern = "*.rs",
    callback = function()
        vim.fn.setreg("g", ":w\r:vsp | terminal cargo run\r")
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
set_autoformat({ "toml" }, false)
set_autoformat({ "lua" }, true)
-- rustfmt is the community standard; there is no style debate to opt out of.
set_autoformat({ "rust" }, true)
