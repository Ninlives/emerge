{ pkgs, config, ... }: {
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
    nixfmt
    moreutils
    encfs
  ];

  programs = {
    man.enable = true;
    zathura.enable = true;
    git = {
      enable = true;
      userName = "mlatus";
      userEmail = "wqseleven@gmail.com";
      ignores = [ ".nixify" ];
    };
  };

  persistent.boxes = [{
    src = /Programs/tldr;
    dst = ".local/tldrc";
  }];
}
