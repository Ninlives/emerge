{ config, pkgs, lib, ... }:
let
  inherit (lib.hm.dag) entryAnywhere;
  tree-sitter-plugins = p:
    with p; [
      tree-sitter-bash
      tree-sitter-c
      tree-sitter-cpp
      tree-sitter-java
      tree-sitter-javascript
      tree-sitter-json
      tree-sitter-latex
      tree-sitter-lua
      tree-sitter-make
      tree-sitter-python
      tree-sitter-query
      tree-sitter-regex
      tree-sitter-vim
      tree-sitter-nix
      # (tree-sitter-nix.overrideAttrs (_: {
      #   version = "fixed";
      #   src = tree-sitter-nix';
      # }))
    ];
in {
  programs.neovim.settings.tree-sitter = entryAnywhere {
    plugins = p:
      with p;
      [
        (nvim-treesitter.withPlugins tree-sitter-plugins)
      ];

    lua = /* lua */ ''
      require("nvim-treesitter.configs").setup {
        highlight = {
          enable = true
        }
      }
    '';
  };
}
