{
  pkgs,
  lib,
  fn,
  config,
  nixosConfig,
  ...
}: let
  inherit (pkgs) rime-data librime fetchFromGitHub;
  inherit (lib.hm.dag) entryAfter;
  inherit (lib) optional optionals optionalString;
  no-im = nixosConfig.i18n.inputMethod.enabled == null;
in {
  programs.neovim.settings.cmp = entryAfter ["basic"] {
    plugins = p:
      with p;
        [
          nvim-cmp
          luasnip

          cmp-nvim-lsp
          cmp-buffer
          cmp-path
        ]
        ++ (optionals no-im [cmp-rime cmp-punc]);

    pythonPackages = p:
      optional no-im (p.buildPythonPackage {
        pname = "pyrime";
        version = "0.1";
        src = fetchFromGitHub {
          owner = "Ninlives";
          repo = "pyrime";
          rev = "721bc94605fc41e27777c6bdf7c4fec4317e8e60";
          sha256 = "sha256-uCGpNryjxkwJ+nAWmnXqDOYuHUAMXKiqR9vcUBmJcUc=";
        };

        buildInputs = [librime];
      });

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
            ${
          optionalString no-im ''
            { name = 'rime', option = {
              shared_data_dir = '${rime-data}/share/rime-data',
              user_data_dir = '${config.home.homeDirectory}/.config/ibus/rime'
            } },
            { name = 'punc' }
          ''
        }
          },
        }

        local opts = { noremap=true, silent=true }
        local on_attach = function(client, bufnr)
        end
        local capabilities = require('cmp_nvim_lsp').default_capabilities()
      '';
  };
}
