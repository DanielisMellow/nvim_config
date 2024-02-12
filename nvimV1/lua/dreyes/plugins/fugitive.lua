return {
    "tpope/vim-fugitive",
    config = function()
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
    end,
}

-- git commit -a -> takes it ready to commit
-- git commit -> Enter the message and it'll commit
-- git push -> to send it out 
