{lib, ...}: let
  inherit (lib.hm.dag) entryAfter;
in {
  programs.neovim.settings.cmp = entryAfter ["basic"] {
    plugins = p:
      with p; [
        nvim-cmp
        luasnip

        cmp-nvim-lsp
        cmp-buffer
        cmp-path
      ];

    lua =
      /*
      lua
      */
      ''
        local cmp = require('cmp')
        local luasnip = require('luasnip')
        cmp.setup {
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          completion = {
            keyword_length = 2,
          },
          mapping = {
            ['<C-p>'] = cmp.mapping.select_prev_item(),
            ['<C-n>'] = cmp.mapping.select_next_item(),
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.close(),
            ['<CR>'] = cmp.mapping.confirm {
              behavior = cmp.ConfirmBehavior.Replace,
              select = true,
            },
            ['<Tab>'] = function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end,
            ['<S-Tab>'] = function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end,
          },
          sources = {
            { name = 'nvim_lsp' },
            { name = 'path' },
            { name = 'buffer' },
          },
        }

        local opts = { noremap=true, silent=true }
        local on_attach = function(client, bufnr)
        end
        local capabilities = require('cmp_nvim_lsp').default_capabilities()
      '';
  };
}
