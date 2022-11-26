{ config, pkgs, lib, ... }:
let
  inherit (pkgs) callPackage page;
  inherit (lib) concatMapStringsSep splitString;
  inherit (config.lib) dirs;
in {
  imports = [ ./extra-config.nix ];
  home.packages = [ (callPackage ./drop-down-kitty.nix { }) page ];
  programs = {
    kitty = {
      enable = true;
      settings = {
        include = "${./gruvbox.conf}";

        font_size = 12;

        disable_ligatures = "always";
        cursor_shape = "underline";

        window_margin_width = "0.3";
        window_padding_width = 3;
        active_border_color = "#689d6a";
        inactive_border_color = "#a89984";

        scrollback_pager_history_size = 4096;
        scrollback_pager = "page -f -b";
        url_prefixes = "http https file ftp exec";
      };
    };
  };

  nixpkgs.overlays = [
    (self: super: {
      fish = super.fish.overrideAttrs(_: { doCheck = false; });
    })
  ];
}
