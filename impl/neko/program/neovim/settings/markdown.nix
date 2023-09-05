{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.hm.dag) entryAfter;
in {
  programs.neovim.settings.markdown = entryAfter ["which-key"] {
    plugins = p:
      with p; [
        vim-table-mode
      ];

    config =
      /*
      vim
      */
      ''
        let g:which_key_map.m = {
        \   'name' : '+markdown' ,
        \   't' : ['TableModeToggle', 'toggle table mode']
        \ }
      '';
  };
}
