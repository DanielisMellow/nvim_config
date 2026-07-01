return {
    "jim-at-jibba/micropython.nvim",
    dependencies = { "folke/snacks.nvim" },
    ft = "python",
    cmd = {
        "MPRun", "MPRunMain", "MPUpload", "MPUploadAll", "MPRepl",
        "MPSync", "MPReset", "MPHardReset",
        "MPListFiles", "MPEraseOne", "MPEraseAll",
        "MPInit", "MPInstall", "MPSetPort", "MPSetBaud", "MPSetStubs", "MPListDevices",
    },
    keys = {
        { "<leader>mr", function() require("micropython_nvim").run() end, desc = "MicroPython: run buffer" },
        { "<leader>mu", "<cmd>MPUpload<cr>", desc = "MicroPython: upload buffer" },
        { "<leader>mU", "<cmd>MPUploadAll<cr>", desc = "MicroPython: upload all" },
        { "<leader>ml", "<cmd>MPRepl<cr>", desc = "MicroPython: REPL" },
        { "<leader>ms", "<cmd>MPSync<cr>", desc = "MicroPython: sync mount" },
        { "<leader>mp", "<cmd>MPSetPort<cr>", desc = "MicroPython: set port" },
        { "<leader>mi", "<cmd>MPInit<cr>", desc = "MicroPython: init project" },
        { "<leader>md", "<cmd>MPListDevices<cr>", desc = "MicroPython: list devices" },
        { "<leader>mf", "<cmd>MPListFiles<cr>", desc = "MicroPython: list device files" },
    },
}
