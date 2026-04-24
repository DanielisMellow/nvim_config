return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                jedi_language_server = {},
                pyright = {
                    autostart = false, -- This tells lspconfig not to start it automatically
                    -- Define the on_attach directly here
                    on_attach = function(client, _)
                        -- Disable hover in favor of Jedi
                        client.server_capabilities.hoverProvider = false
                    end,
                },
            },
        },
        keys = {
            {
                "<leader>I",
                function()
                    -- 'get_active_clients' is deprecated, use 'get_clients'
                    local clients = vim.lsp.get_clients({ name = "pyright", bufnr = 0 })

                    if #clients == 0 then
                        -- This works because we allowed the default setup to run (didn't return false)
                        vim.cmd("LspStart pyright")
                        vim.notify("Pyright started", vim.log.levels.INFO)
                    else
                        vim.cmd("LspStop pyright")
                        vim.notify("Pyright stopped", vim.log.levels.INFO)
                    end
                end,
                desc = "Toggle Pyright",
            },
        },
    },
}
