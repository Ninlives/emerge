{ config, pkgs, lib, fn, ... }:
let
  inherit (pkgs) gnome;
  inherit (pkgs.nixos-cn) touchegg;
  inherit (lib) concatMapStringsSep;
in {
  system.nixos.tags =
    [ "Gnome-${config.boot.kernelPackages.kernel.modDirVersion}" ];

  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;

  environment.gnome.excludePackages = with gnome; [
    gnome-software
    epiphany
    gnome-maps
    gedit
    geary
    gnome-todo
    gnome-contacts
    gnome-packagekit
  ];
  services.gnome.gnome-user-share.enable = false;
  services.gnome.tracker-miners.enable = false;
  services.gnome.tracker.enable = false;

  services.gnome.sushi.enable = true;

  environment.systemPackages =
    [ gnome.gnome-tweaks pkgs.networkmanagerapplet pkgs.thunderbird ];

  systemd.packages = [ touchegg ];
  systemd.services.touchegg.wantedBy = [ "multi-user.target" ];

  revive.specifications.user.boxes = [
    {
      src = /Programs/gnome/data/keyrings;
      dst = fn.home ".local/share/keyrings";
    }
    {
      src = /Programs/gnome/state/goa;
      dst = fn.home ".config/goa-1.0";
    }
  ];
}
