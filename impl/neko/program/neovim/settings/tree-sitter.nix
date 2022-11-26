{ config, pkgs, lib, ... }:
let
  inherit (pkgs) fetchFromGitHub;
  inherit (lib.hm.dag) entryAnywhere;
  tree-sitter-nix' = fetchFromGitHub {
    owner = "oxalica";
    repo = "tree-sitter-nix";
    rev = "add8eb3050a0974c1854df419c192fa4f359bcb0";
    sha256 = "0hd7si3qr6yj2lv63x05v9jad9qb11rm0i3v42507r19vppalqn7";
  };
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
        ((nvim-treesitter.withPlugins tree-sitter-plugins).overrideAttrs (prev: {
          # postInstall = prev.postInstall or "" + ''
          #   for x in highlights locals injections indents; do
          #     cp -f ${tree-sitter-nix'}/queries/nvim-$x.scm $out/queries/nix/$x.scm
          #   done
          # '';
        }))
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
