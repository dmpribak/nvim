return {
    "nvim-lualine/lualine.nvim",
    requires = { "nvim-tree/nvim-web-devicons", opt = true },
    event = "ColorScheme",
    config = function()
        require("lualine").setup({
            options = {
                theme = "rose-pine"
            },
            sections = {
                lualine_x = { "filetype" }
            }
        })
    end
}
