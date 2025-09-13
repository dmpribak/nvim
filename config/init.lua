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
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.cmd("syntax on")
vim.g.mapleader = " "

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

-- venn.nvim: enable or disable keymappings
function _G.Toggle_venn()
    local venn_enabled = vim.inspect(vim.b.venn_enabled)
    if venn_enabled == "nil" then
        vim.b.venn_enabled = true
        vim.cmd[[setlocal ve=all]]
        -- draw a line on HJKL keystokes
        vim.api.nvim_buf_set_keymap(0, "n", "J", "<C-v>j:VBox<CR>", {noremap = true})
        vim.api.nvim_buf_set_keymap(0, "n", "K", "<C-v>k:VBox<CR>", {noremap = true})
        vim.api.nvim_buf_set_keymap(0, "n", "L", "<C-v>l:VBox<CR>", {noremap = true})
        vim.api.nvim_buf_set_keymap(0, "n", "H", "<C-v>h:VBox<CR>", {noremap = true})
        -- draw a box by pressing "f" with visual selection
        vim.api.nvim_buf_set_keymap(0, "v", "f", ":VBox<CR>", {noremap = true})
    else
        vim.cmd[[setlocal ve=]]
        vim.api.nvim_buf_del_keymap(0, "n", "J")
        vim.api.nvim_buf_del_keymap(0, "n", "K")
        vim.api.nvim_buf_del_keymap(0, "n", "L")
        vim.api.nvim_buf_del_keymap(0, "n", "H")
        vim.api.nvim_buf_del_keymap(0, "v", "f")
        vim.b.venn_enabled = nil
    end
end
-- toggle keymappings for venn using <leader>v
vim.api.nvim_set_keymap('n', '<leader>v', ":lua Toggle_venn()<CR>", { noremap = true})

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
vim.lsp.enable("lua_ls")

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
require("lspconfig")["lua_ls"].setup {
    on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path..'/.luarc.json') or vim.uv.fs_stat(path..'/.luarc.jsonc')) then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT'
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
          -- Depending on the usage, you might want to add additional paths here.
          -- "${3rd}/luv/library"
          -- "${3rd}/busted/library",
        }
        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
        -- library = vim.api.nvim_get_runtime_file("", true)
      }
    })
  end,
  settings = {
    Lua = {}
  }
}

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

require("neo-tree").setup({
    window = {
        mappings = {
            ["I"] = {
                function(state)
                    local node = state.tree:get_node()
                    -- print("yanked", node.path)
                    vim.fn.setreg("", node.path)
                    vim.fn.setreg("0", node.path)
                    vim.fn.setreg("*", node.path)
                    vim.fn.setreg("+", node.path)
                end,
                desc = "copy path"
            }
        }
    }
})
