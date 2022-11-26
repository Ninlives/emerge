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
    ];

    fontconfig.defaultFonts = {
      monospace = font-list;
      sansSerif = font-list;
      serif = font-list;
    };
  };
}
