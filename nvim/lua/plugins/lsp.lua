return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                jedi_language_server = {
                    init_options = {
                        workspace = {
                            extraPaths = { "typings" },
                        },
                    },
                },
                pyright = {
                    autostart = false, -- This tells lspconfig not to start it automatically
                    -- Define the on_attach directly here
                    on_attach = function(client, _)
                        -- Disable hover in favor of Jedi
                        client.server_capabilities.hoverProvider = false
                    end,
                },
                autotools_ls = {},
                just = {},
            },
        },
        keys = {
            {
                "<leader>I",
                function()
                    local clients = vim.lsp.get_clients({ name = "pyright", bufnr = 0 })

                    if #clients == 0 then
                        vim.lsp.enable("pyright")
                        vim.notify("Pyright started", vim.log.levels.INFO)
                    else
                        vim.lsp.enable("pyright", false)
                        vim.notify("Pyright stopped", vim.log.levels.INFO)
                    end
                end,
                desc = "Toggle Pyright",
            },
        },
    },
}
