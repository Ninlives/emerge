{ pkgs, lib, ... }:
with pkgs;
let
  font-list =[ "ShareTechMono Nerd Font Mono" "Sarasa Mono Slab SC" ];
in
{
  fonts = {
    packages = lib.mkForce [
      sarasa-gothic
      (nerdfonts.override { fonts = [ "ShareTechMono" ]; })
      twitter-color-emoji
      noto-fonts
      noto-fonts-cjk
      liberation_ttf
      wqy_zenhei
    ];

    # fontDir.enable = true;
    fontconfig = {
      cache32Bit = true;
      antialias = true;
      subpixel = {
        rgba = "none";
        lcdfilter = "none";
      };
    };

    fontconfig.defaultFonts = {
      monospace = font-list;
      sansSerif = font-list;
      serif = font-list;
    };
  };
}
