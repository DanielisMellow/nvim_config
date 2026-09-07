return {
    {
        "mfussenegger/nvim-dap-python",
        config = function()
            local dap = require("dap")
            local dap_python = require("dap-python")

            -- Register nvim-dap-python's default configurations (launch file,
            -- launch with args, pytest method/class, etc.). The interpreter we
            -- pass here is only a placeholder for registration -- the adapter
            -- below decides which Python actually runs, so we don't hard-code a
            -- path that may or may not exist per project.
            dap_python.setup("python3")

            -- Run the debug adapter through uv, layering debugpy onto the
            -- project env with `--with`. This guarantees debugpy is available
            -- without adding it to the project's dependencies, and fixes the
            -- adapter exiting when the resolved interpreter (e.g. the system
            -- /usr/sbin/python) has no debugpy installed. The debuggee is
            -- spawned from the adapter's own interpreter, so it inherits the
            -- same environment -- project packages plus debugpy. This mirrors
            -- the `uv run python` used by the @g run-file macro.
            dap.adapters.python = function(cb, config)
                if config.request == "attach" then
                    local conn = config.connect or config
                    cb({
                        type = "server",
                        host = conn.host or "127.0.0.1",
                        port = assert(conn.port, "`connect.port` is required for a python attach configuration"),
                        options = { source_filename = config.program },
                    })
                else
                    cb({
                        type = "executable",
                        command = "uv",
                        args = { "run", "--with", "debugpy", "python", "-m", "debugpy.adapter" },
                    })
                end
            end

            -- Let the debuggee inherit the adapter's uv-managed interpreter
            -- instead of a fixed pythonPath, so `uv run` decides the env.
            for _, cfg in ipairs(dap.configurations.python or {}) do
                cfg.pythonPath = nil
                cfg.python = nil
            end
        end,
    },
}
