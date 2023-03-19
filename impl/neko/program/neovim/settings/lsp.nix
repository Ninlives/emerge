{ pkgs, lib, config, fn, nixosConfig, ... }:
let
  inherit (pkgs) nil texlab pyright;
  inherit (pkgs.nodePackages) bash-language-server;
  inherit (lib.hm.dag) entryAfter;
in {
  programs.neovim.settings.lsp = entryAfter [ "cmp" ] {
    plugins = p: with p; [ nvim-lspconfig ];
    extraPackages = [ nil bash-language-server texlab pyright ];

    lua = /* lua */ ''
      local lsps = { 'nil_ls', 'bashls', 'pyright', 'texlab' }
      local lspconfig = require('lspconfig')
      for _, lsp in pairs(lsps) do
        lspconfig[lsp].setup {
            on_attach = on_attach,
            capabilities = capabilities,
        }
      end
    '';
  };
}
