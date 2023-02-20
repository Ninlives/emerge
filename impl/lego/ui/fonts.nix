{ config, pkgs, lib, inputs, ... }:
with pkgs;
let
  font-list =[ "ShureTechMono Nerd Font Mono" "Sarasa Mono Slab SC" ];
in
{
  fonts = {
    fonts = lib.mkForce [
      sarasa-gothic
      (nerdfonts.override { fonts = [ "ShareTechMono" ]; })
      twitter-color-emoji
      noto-fonts
      noto-fonts-cjk
      liberation_ttf
      wqy_zenhei
    ];

    fontDir.enable = true;
    fontconfig.cache32Bit = true;

    fontconfig.defaultFonts = {
      monospace = font-list;
      sansSerif = font-list;
      serif = font-list;
    };
  };
}
