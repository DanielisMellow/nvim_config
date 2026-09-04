-- lua/plugins/rust.lua
--
-- Rust tuning on top of `lazyvim.plugins.extras.lang.rust` (imported in
-- lua/config/lazy.lua). The extra brings rustaceanvim, crates.nvim, the
-- treesitter parsers and the codelldb debug adapter; everything here is
-- learning-oriented sugar on top of that.
--
-- rust-analyzer itself is expected on $PATH from rustup
-- (`rustup component add rust-analyzer`), not from mason, so that it always
-- matches the toolchain the project is actually built with.

return {
    {
        "mrcjkb/rustaceanvim",
        opts = function(_, opts)
            -- The LazyVim extra already installs an on_attach that maps
            -- <leader>cR / <leader>dr. Wrap it instead of replacing it.
            local base_on_attach = vim.tbl_get(opts, "server", "on_attach")

            opts.server = opts.server or {}
            opts.server.on_attach = function(client, bufnr)
                if base_on_attach then
                    base_on_attach(client, bufnr)
                end

                local function map(lhs, action, desc)
                    vim.keymap.set("n", lhs, function()
                        vim.cmd.RustLsp(action)
                    end, { buffer = bufnr, desc = desc })
                end

                -- Hover actions: docs plus "go to impl / show type" jump list.
                -- Press K twice to jump into the popup.
                vim.keymap.set("n", "K", function()
                    vim.cmd.RustLsp({ "hover", "actions" })
                end, { buffer = bufnr, desc = "Hover Actions (Rust)" })

                -- The two that matter most while learning: the full cargo-style
                -- rendering of a diagnostic, and the long-form rustc --explain.
                map("<leader>rd", "renderDiagnostic", "Render Diagnostic (cargo style)")
                map("<leader>re", "explainError", "Explain Error (rustc --explain)")

                map("<leader>rr", "runnables", "Runnables")
                map("<leader>rt", "testables", "Testables")
                map("<leader>rD", "debuggables", "Debuggables")
                map("<leader>rm", "expandMacro", "Expand Macro")
                map("<leader>rp", "parentModule", "Parent Module")
                map("<leader>rc", "openCargo", "Open Cargo.toml")
                map("<leader>rw", "openDocs", "Open docs.rs for Symbol")
                map("<leader>ra", "codeAction", "Code Action (grouped)")
            end

            opts.server.default_settings = opts.server.default_settings or {}
            local ra = opts.server.default_settings["rust-analyzer"] or {}
            opts.server.default_settings["rust-analyzer"] = ra

            -- Lint with clippy on save, not just cargo check: clippy is where
            -- "this compiles but isn't idiomatic Rust" feedback comes from.
            ra.check = vim.tbl_deep_extend("force", ra.check or {}, {
                command = "clippy",
                extraArgs = { "--no-deps" },
            })

            -- Inlay hints do a lot of the teaching here — they show the types
            -- that inference worked out and the lifetimes that were elided.
            ra.inlayHints = {
                bindingModeHints = { enable = true },
                chainingHints = { enable = true },
                closingBraceHints = { enable = true, minLines = 20 },
                closureReturnTypeHints = { enable = "with_block" },
                lifetimeElisionHints = { enable = "skip_trivial", useParameterNames = true },
                parameterHints = { enable = true },
                -- `reborrowHints` is a deprecated alias that switches on the
                -- broader expression-adjustment hints, which wrap half the
                -- buffer in `(&*x)` noise. Say what we actually mean instead.
                expressionAdjustmentHints = { enable = "never" },
                renderColons = true,
                typeHints = { enable = true },
            }

            -- Fill in argument placeholders on completion, and group auto
            -- imports per module rather than one `use` line per item.
            ra.completion = vim.tbl_deep_extend("force", ra.completion or {}, {
                callable = { snippets = "fill_arguments" },
                fullFunctionSignatures = { enable = true },
            })
            ra.imports = vim.tbl_deep_extend("force", ra.imports or {}, {
                granularity = { group = "module" },
            })

            return opts
        end,
    },

    -- Cargo.toml editing: crates.nvim is already configured by the extra,
    -- these are the keymaps for it (buffer-local to Cargo.toml).
    {
        "Saecki/crates.nvim",
        init = function()
            vim.api.nvim_create_autocmd("BufRead", {
                group = vim.api.nvim_create_augroup("crates_keymaps", { clear = true }),
                pattern = "Cargo.toml",
                callback = function(ev)
                    local function map(lhs, fn, desc)
                        vim.keymap.set("n", lhs, function()
                            require("crates")[fn]()
                        end, { buffer = ev.buf, desc = desc })
                    end

                    map("<leader>rv", "show_versions_popup", "Crate Versions")
                    map("<leader>rf", "show_features_popup", "Crate Features")
                    map("<leader>ru", "update_crate", "Update Crate")
                    map("<leader>rU", "upgrade_crate", "Upgrade Crate (bump req)")
                    map("<leader>rA", "upgrade_all_crates", "Upgrade All Crates")
                    map("<leader>rH", "open_homepage", "Open Crate Homepage")
                    map("<leader>rR", "open_documentation", "Open Crate Docs")
                end,
            })
        end,
    },

    -- Register the <leader>r prefix so which-key labels the group.
    {
        "folke/which-key.nvim",
        opts = {
            spec = {
                { "<leader>r", group = "rust", icon = "󱘗 " },
            },
        },
    },
}
