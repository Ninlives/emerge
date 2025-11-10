{...}: {
  programs = {
    zsh = {
      initContent = ''
        kitty + complete setup zsh | source /dev/stdin
      '';
      shellAliases.gdiff = "git difftool --no-symlinks --dir-diff";
    };
    git = {
      settings = {
        diff = {
          tool = "kitty";
          guitool = "kitty.gui";
        };
        difftool = {
          prompt = false;
          trustExitCode = true;
        };
        "difftool \"kitty\"".cmd = "kitty +kitten diff $LOCAL $REMOTE";
        "difftool \"kitty.gui\"".cmd = "kitty kitty +kitten diff $LOCAL $REMOTE";
      };
    };
  };
}
