{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.hm.dag) entryAfter;
in {
  programs.neovim.settings.surround = entryAfter ["which-key"] {
    plugins = p:
      with p; [
        vim-surround
      ];

    lua =
      /*
      lua
      */
      ''
        require('which-key').add({
          { "<leader>s", group = "surround" },
          { "<leader>sC", "<Plug>CSurround", desc = "change selected" },
          { "<leader>sI", "<Plug>YSurround", desc = "insert multiline" },
          { "<leader>sc", "<Plug>Csurround", desc = "change" },
          { "<leader>sd", "<Plug>Dsurround", desc = "delete" },
          { "<leader>si", "<Plug>Ysurround", desc = "insert" },
        })
      '';
  };
}
