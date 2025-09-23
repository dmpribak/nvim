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

vim.keymap.set("n", "<C-k>", function() vim.cmd("Neotree toggle reveal") end)
vim.keymap.set("n", "<leader>k", function() vim.cmd("AerialNavToggle") end)
vim.keymap.set("n", "<leader>ni", function() vim.cmd("Neorg index") end)
vim.keymap.set("n", "<leader>nr", function() vim.cmd("Neorg return") end)

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
    ensure_installed = { "python", "lua", "nix", "regex", "markdown", "markdown_inline" },
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
    -- completion = {callSnippet = "Replace"},
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path"},
        -- { name = "nvim_lsp_signature_help" },
    }, {
        { name = "buffer" },
    }
    )
})

-- require("lsp_signature").setup()

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
vim.lsp.enable("pyright")
vim.lsp.enable("nixd")
vim.lsp.enable("lua_ls")
vim.lsp.enable("clangd")

vim.lsp.config("pyright", {
    capabilities=capabilities
})

vim.lsp.config("nixd", {
    capabilities=capabilities,
    settings = {
        nixd = {
            formatting = {
                command = { "nixfmt" }
            }
        }
    }
})

vim.lsp.config("lua_ls", {
    capabilities=capabilities,
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
})
vim.lsp.config("clangd", {
    capabilities = capabilities
})
-- require("lspconfig")["pyright"].setup {
--     capabilities = capabilities
-- }
-- require("lspconfig")["nixd"].setup {
--     capabilities = capabilities
-- }
-- require("lspconfig").nixd.setup({
-- })
-- require("lspconfig")["lua_ls"].setup {
--     on_init = function(client)
--     if client.workspace_folders then
--       local path = client.workspace_folders[1].name
--       if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path..'/.luarc.json') or vim.uv.fs_stat(path..'/.luarc.jsonc')) then
--         return
--       end
--     end
--
--     client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
--       runtime = {
--         -- Tell the language server which version of Lua you're using
--         -- (most likely LuaJIT in the case of Neovim)
--         version = 'LuaJIT'
--       },
--       -- Make the server aware of Neovim runtime files
--       workspace = {
--         checkThirdParty = false,
--         library = {
--           vim.env.VIMRUNTIME
--           -- Depending on the usage, you might want to add additional paths here.
--           -- "${3rd}/luv/library"
--           -- "${3rd}/busted/library",
--         }
--         -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
--         -- library = vim.api.nvim_get_runtime_file("", true)
--       }
--     })
--   end,
--   settings = {
--     Lua = {}
--   }
-- }

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

require("gitsigns").setup({
    current_line_blame = true,

    on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
            if vim.wo.diff then
                vim.cmd.normal({']c', bang = true})
            else
                gitsigns.nav_hunk('next')
            end
        end)

        map('n', '[c', function()
            if vim.wo.diff then
                vim.cmd.normal({'[c', bang = true})
            else
                gitsigns.nav_hunk('prev')
            end
        end)

        map('n', '<leader>hi', gitsigns.preview_hunk_inline)
    end

})

require("aerial").setup({
    on_attach = function(bufnr)
        vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
        vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
    end,
})

local actions = require("telescope.actions")
require("telescope").setup({
    defaults = {
        mappings = {
            n = {
                ["<leader>fq"] = actions.close
            }
        },
        layout_config = {
            -- height = 0.75,
            -- width = 0.75
        }
    },
    pickers = {
        buffers = {
            sort_mru = true,
            ignore_current_buffer = true,
            mappings = {
                i = {
                    ["<C-d>"] = actions.delete_buffer + actions.move_to_top
                }
            }
        }
    }
})
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.git_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
