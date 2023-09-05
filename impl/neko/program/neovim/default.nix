{
  fn,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [./options.nix] ++ fn.dotNixFrom ./settings;
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withRuby = true;
    withNodeJs = true;
  };
  persistent.boxes = [
    {
      src = /Programs/neovim/main/data;
      dst = ".local/share/nvim";
    }
    {
      src = /Programs/neovim/main/state;
      dst = ".local/state/nvim";
    }
    {
      src = /Programs/neovim/main/undo;
      dst = ".local/undodir";
    }
  ];
}
