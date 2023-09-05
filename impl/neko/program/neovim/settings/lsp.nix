{
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs) nil texlab pyright ltex-ls;
  inherit (pkgs.nodePackages) bash-language-server;
  inherit (lib.hm.dag) entryAfter;
in {
  programs.neovim.settings.lsp = entryAfter ["cmp"] {
    plugins = p: with p; [nvim-lspconfig];
    extraPackages = [nil bash-language-server texlab pyright ltex-ls];

    lua =
      /*
      lua
      */
      ''
        local lsps = { 'nil_ls', 'bashls', 'pyright', 'texlab', 'ltex'}
        local lspconfig = require('lspconfig')
        for _, lsp in pairs(lsps) do
          lspconfig[lsp].setup {
            on_attach = on_attach,
            capabilities = capabilities,
          }
        end

        local ltex_types = lspconfig.ltex.document_config.default_config.filetypes
        lspconfig.ltex.setup {
          on_attach = on_attach,
          capabilities = capabilities,
          filetypes = ltex_types,
          settings = {
            ltex = {
              enabled = ltex_types
            }
          }
        }
      '';
  };
}
