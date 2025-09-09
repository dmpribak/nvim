return {
    {
        "akinsho/bufferline.nvim",
        event = "ColorScheme",
        config = function()
            require("bufferline").setup({
                highlights = require("rose-pine.plugins.bufferline")
            })
        end
    }
}
