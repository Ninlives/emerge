{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    # Command Line
    xclip
    axel
    fd
    jq
    man-pages
    gnumake
    neofetch
    nix-top
    ripgrep
    translate-shell
    gotop
    nix-index
    tldr
    ffmpeg
    tree
    moreutils
    encfs
    zip
    unzip
  ];
  programs = {
    man.enable = true;
    git.enable = true;
  };

  persistent.boxes = [
    {
      src = /Programs/tldr;
      dst = ".tldrc";
    }
  ];
}
