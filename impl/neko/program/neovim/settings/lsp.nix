{ pkgs, lib, config, fn, nixosConfig, ... }:
let
  inherit (pkgs) rnix-lsp texlab pyright;
  inherit (pkgs.nodePackages) bash-language-server;
  inherit (lib.hm.dag) entryAfter;
in {
  programs.neovim.settings.lsp = entryAfter [ "cmp" ] {
    plugins = p: with p; [ nvim-lspconfig ];
    extraPackages = [ rnix-lsp bash-language-server texlab pyright ];

    lua = /* lua */ ''
      local lsps = { 'rnix', 'bashls', 'pyright', 'texlab' }
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
