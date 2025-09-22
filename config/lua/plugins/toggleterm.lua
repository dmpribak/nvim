return {
  {
      'akinsho/toggleterm.nvim', 
      version = "*", 
      event = "ColorScheme",
      config = function()
          local highlights = require("rose-pine.plugins.toggleterm")
          require("toggleterm").setup({highlights = highlights})
      end
  }
}
