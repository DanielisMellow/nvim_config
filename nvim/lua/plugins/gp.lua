-- ~/.config/nvim/lua/plugins/gp.lua
return {
    {
        "robitx/gp.nvim",
        event = "VeryLazy",
        config = function()
            local defaults = require("gp.defaults")

            require("gp").setup({
                -- 1Password CLI
                openai_api_key = {
                    "op",
                    "item",
                    "get",
                    "openai",
                    "--vault",
                    "Employee",
                    "--fields",
                    "credential",
                    "--reveal",
                },

                providers = {
                    openai = { disable = false, endpoint = "https://api.openai.com/v1/chat/completions" },
                    azure = { disable = true },
                    copilot = { disable = true },
                    ollama = { disable = true },
                    lmstudio = { disable = true },
                    googleai = { disable = true },
                    pplx = { disable = true },
                    anthropic = { disable = true },
                },

                default_chat_agent = "ChatGPT4o",
                default_command_agent = "CodeGPT4o",

                agents = {
                    {
                        name = "ChatGPT4o",
                        chat = true,
                        command = false,
                        model = { model = "gpt-4o", temperature = 0.3, top_p = 0.9 },
                        system_prompt = [[
You are a helpful, concise assistant embedded in Neovim.
Prefer short answers with clear steps or code snippets.
When code is requested, reply with minimal surrounding prose.
            ]],
                    },
                    {
                        name = "CodeGPT4o",
                        chat = false,
                        command = true,
                        model = { model = "gpt-4o", temperature = 0.1, top_p = 0.1 },
                        system_prompt = defaults.code_system_prompt,
                    },
                },

                -- Make it feel like ChatGPT
                toggle_target = "popup",
                style_popup_border = "rounded",
                style_popup_max_width = 160,
                log_sensitive = false,

                -- 🟢 Use <leader>c<Enter> to SEND in chat buffers
                chat_shortcut_respond = { modes = { "n", "i", "v", "x" }, shortcut = "<leader>c<CR>" },
                -- (you can add matching shortcuts for stop/new/delete if you like)
                -- chat_shortcut_stop   = { modes = { "n","i","v","x" }, shortcut = "<leader>cs" },
                -- chat_shortcut_new    = { modes = { "n","i","v","x" }, shortcut = "<leader>cc" },
                -- chat_shortcut_delete = { modes = { "n","i","v","x" }, shortcut = "<leader>cd" },
            })

            -- Keymaps
            local map = vim.keymap.set
            local function d(s)
                return { noremap = true, silent = true, nowait = true, desc = "GP: " .. s }
            end

            -- Chat
            map({ "n", "i" }, "<leader>cg", "<cmd>GpChatToggle popup<cr>", d("Toggle Chat"))
            map({ "n", "i" }, "<leader>cn", "<cmd>GpChatNew popup<cr>", d("New Chat"))
            map({ "n", "i" }, "<leader>cf", "<cmd>GpChatFinder<cr>", d("Chat Finder"))

            -- Code ops
            map({ "n", "v" }, "<leader>ce", "<cmd>GpRewrite<cr>", d("Edit / Rewrite"))
            map({ "n", "v" }, "<leader>cx", "<cmd>GpPopup<cr>", d("Explain in Popup"))
            map({ "n", "v" }, "<leader>ca", "<cmd>GpAppend<cr>", d("Append"))
            map({ "n", "v" }, "<leader>cp", "<cmd>GpPrepend<cr>", d("Prepend"))

            -- Agents
            map({ "n", "i", "v", "x" }, "<leader>cl", "<cmd>GpSelectAgent<cr>", d("Select Agent"))
            map({ "n", "i", "v", "x" }, "<leader>c.", "<cmd>GpNextAgent<cr>", d("Next Agent"))
            map({ "n", "i", "v", "x" }, "<leader>cs", "<cmd>GpStop<cr>", d("Stop Generation"))

            -- 🔒 Failsafe: global map to send (works even if buffer-local shortcut didn’t load)
            map("n", "<leader>gc", "<cmd>GpChatRespond<cr>", d("Chat: Send"))
        end,
    },
}
