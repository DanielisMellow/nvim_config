return {
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {
            ensure_installed = {
                "pyright",
                "jedi_language_server",
                "autotools_ls",
                "just",
            },
        },
    },
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "ruff",
                "pylint",
                "taplo",
            },
        },
    },
}
