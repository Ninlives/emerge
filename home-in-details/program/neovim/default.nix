{ config, pkgs, lib, out-of-world, ... }:
let
  inherit (out-of-world.function) excludeDisabledFrom;
in {
  imports = [ ./options.nix ] ++ excludeDisabledFrom ./settings;
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withRuby = true;
    withNodeJs = true;
  };
  persistent.boxes = [
    { src = /Programs/neovim/main/data; dst = ".local/share/nvim"; }
    { src = /Programs/neovim/main/undo; dst = ".local/undodir"; }
    { src = /Programs/neovim/coc; dst = ".config/coc"; }
  ];
}

