vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.autoindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.showmatch = true
vim.opt.matchtime = 3
vim.opt.cursorline = true
vim.cmd("syntax on")

-- Keybinds --
vim.keymap.set({"i", "t"}, "jk", "<C-\\><C-n>")
vim.keymap.set({"i", "t"}, "jK", "<C-\\><C-n>")
vim.keymap.set({"i", "t"}, "Jk", "<C-\\><C-n>")
vim.keymap.set({"i", "t"}, "JK", "<C-\\><C-n>")

vim.keymap.set({"i", "n", "t"}, "<A-h>", "<C-\\><C-n><C-w>h")
vim.keymap.set({"i", "n", "t"}, "<A-j>", "<C-\\><C-n><C-w>j")
vim.keymap.set({"i", "n", "t"}, "<A-k>", "<C-\\><C-n><C-w>k")
vim.keymap.set({"i", "n", "t"}, "<A-l>", "<C-\\><C-n><C-w>l")

vim.keymap.set("n", "<C-k>", ":Neotree toggle reveal<cr>")

-- Plugins --
require("config.lazy")

require("nvim-treesitter.configs").setup {
    ensure_installed = { "python", "lua", "nix" },
    auto_install = true,
    highlight = {
        enable = true
    }
}

vim.lsp.enable("pyright")
vim.lsp.enable("nixd")

local cmp = require("cmp")

cmp.setup({
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered()
    },
    completion = {callSnippet = "Replace"},
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path"},
        { name = "luasnip" },
        { name = "nvim_lsp_signature_help" },
    })
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
require("lspconfig")["pyright"].setup {
    capabilities = capabilities
}
require("lspconfig")["nixd"].setup {
    capabilities = capabilities
}
require("lspconfig").nixd.setup({
    settings = {
        nixd = {
            formatting = {
                command = { "nixfmt" }
            }
        }
    }
})

require("toggleterm").setup{
    open_mapping = [[<C-\>]]
}

vim.cmd[[
" Use Tab to expand and jump through snippets
imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
smap <silent><expr> <Tab> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<Tab>'

" Use Shift-Tab to jump backwards through snippets
imap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
smap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
]]

-- require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/LuaSnip/"})
require("luasnip").config.set_config({
    enable_autosnippets = true,
    store_selection_keys = "<Tab>"
})

require("smear_cursor").setup()

require("conform").setup({
    formatter_by_ft = {
        nix = { "nixfmt" }
    }
})

vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })
