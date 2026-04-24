-- lua/plugins/fl.lua
return {
    {
        -- No real plugin needed; this entry just runs our config at startup.
        dir = vim.fn.stdpath("config"),
        name = "fstring-converter",
        event = "VeryLazy",
        config = function()
            -- Scan-based converter: robust to the previous gsub weirdness.
            local function convert_fstring_anywhere(line)
                -- find f" or f'
                local s = line:find("[fF][\"']")
                if not s then
                    return nil
                end
                local q = line:sub(s + 1, s + 1) -- quote char
                if q ~= '"' and q ~= "'" then
                    return nil
                end

                -- find end quote (simple: next same quote)
                local e = line:find(q, s + 2)
                if not e then
                    return nil
                end

                local pre = line:sub(1, s - 1)
                local inner = line:sub(s + 2, e - 1)
                local post = line:sub(e + 1)

                -- build new inner and collect vars
                local out = {}
                local vars = {}
                local i, n = 1, #inner
                while i <= n do
                    local c = inner:sub(i, i)
                    if c == "{" then
                        -- handle escaped '{{'
                        if i + 1 <= n and inner:sub(i + 1, i + 1) == "{" then
                            table.insert(out, "{")
                            i = i + 2
                        else
                            -- parse { ... } with nesting
                            local depth = 1
                            local j = i + 1
                            while j <= n and depth > 0 do
                                local cj = inner:sub(j, j)
                                if cj == "{" then
                                    depth = depth + 1
                                elseif cj == "}" then
                                    depth = depth - 1
                                end
                                j = j + 1
                            end
                            if depth ~= 0 then
                                return nil -- unbalanced
                            end
                            local expr = inner:sub(i + 1, j - 2):gsub("^%s+", ""):gsub("%s+$", "")
                            if expr == "" then
                                -- leave "{}" alone if somehow empty
                                table.insert(out, "{}")
                            else
                                table.insert(out, "%s")
                                table.insert(vars, expr)
                            end
                            i = j
                        end
                    elseif c == "}" then
                        -- handle escaped '}}'
                        if i + 1 <= n and inner:sub(i + 1, i + 1) == "}" then
                            table.insert(out, "}")
                            i = i + 2
                        else
                            -- stray '}' — keep as-is
                            table.insert(out, "}")
                            i = i + 1
                        end
                    else
                        table.insert(out, c)
                        i = i + 1
                    end
                end

                if #vars == 0 then
                    return nil -- nothing to convert
                end

                local replaced = q .. table.concat(out) .. q
                local vars_str = table.concat(vars, ", ")

                -- If right after the f-string comes a ')', inject args before it
                if post:match("^%s*%)") then
                    post = ", " .. vars_str .. post
                -- If there’s a comma (more args), put our vars right after the string
                elseif post:match("^%s*,") then
                    replaced = replaced .. ", " .. vars_str
                else
                    -- generic case: append vars after the string (assignments, prints, etc.)
                    replaced = replaced .. ", " .. vars_str
                end

                return pre .. replaced .. post
            end

            local function convert_current_line()
                local line = vim.api.nvim_get_current_line()
                local converted = convert_fstring_anywhere(line)
                if converted then
                    vim.api.nvim_set_current_line(converted)
                    vim.notify("Converted f-string → %s style (+args)", vim.log.levels.INFO)
                else
                    vim.notify("No convertible f-string on this line", vim.log.levels.WARN)
                end
            end

            local function convert_visual_selection()
                local bufnr = 0
                local srow = vim.fn.getpos("v")[2]
                local erow = vim.fn.getpos(".")[2]
                if srow > erow then
                    srow, erow = erow, srow
                end

                local any = false
                for row = srow, erow do
                    local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
                    local converted = convert_fstring_anywhere(line)
                    if converted then
                        vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, { converted })
                        any = true
                    end
                end
                if any then
                    vim.notify("Converted f-strings in selection → %s style (+args)", vim.log.levels.INFO)
                else
                    vim.notify("No convertible f-strings in selection", vim.log.levels.WARN)
                end
            end

            vim.keymap.set(
                "n",
                "<leader>fl",
                convert_current_line,
                { desc = "Convert f-string → %s logging (+args)" }
            )
            vim.keymap.set(
                "x",
                "<leader>fl",
                convert_visual_selection,
                { desc = "Convert f-strings (selection) → %s logging (+args)" }
            )
        end,
    },
}
