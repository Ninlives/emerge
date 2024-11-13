{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.hm.dag) entryAfter;
in {
  programs.neovim.settings.caw = entryAfter ["which-key"] {
    plugins = p: [p.caw-vim];

    lua =
      /*
      lua
      */
      ''
        require('which-key').add({
          { "<leader>c", group = "comment" },
          { "<leader>cI", "<Plug>(caw:zeropos:comment)", desc = "zeropos" },
          { "<leader>cO", "<Plug>(caw:jump:comment-prev)", desc = "jump prev" },
          { "<leader>ca", "<Plug>(caw:dollarpos:comment)", desc = "dollarpos" },
          { "<leader>cb", "<Plug>(caw:box:comment)", desc = "box" },
          { "<leader>ci", "<Plug>(caw:hatpos:comment)", desc = "hatpos" },
          { "<leader>co", "<Plug>(caw:jump:comment-next)", desc = "jump next" },

          { "<leader>cu", group = "uncomment" },
          { "<leader>cuI", "<Plug>(caw:zeropos:uncomment)", desc = "zeropos" },
          { "<leader>cua", "<Plug>(caw:dollarpos:uncomment)", desc = "dollarpos" },
          { "<leader>cui", "<Plug>(caw:hatpos:uncomment)", desc = "hatpos" },
          { "<leader>cuw", "<Plug>(caw:wrap:uncomment)", desc = "wrap" },
          { "<leader>cw", "<Plug>(caw:wrap:comment)", desc = "wrap" },
        })
      '';
  };
}
