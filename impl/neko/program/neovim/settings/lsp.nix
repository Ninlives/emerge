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
        for _, lsp in pairs(lsps) do
          vim.lsp.enable(lsp)
        end

        vim.lsp.config('nil_ls', {
          settings = {
            ['nil'] = {
              nix = {
                flake = {
                  autoArchive = false
                }
              }
            }
          }
        })
      '';
  };
}
