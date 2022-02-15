{ config, pkgs, lib, constant, out-of-world, ... }:
let
  inherit (pkgs) gnome3;
  inherit (pkgs.nixos-cn) touchegg;
  inherit (lib) concatMapStringsSep;
  inherit (constant) user;
  inherit (out-of-world) dirs;
  mainUser = user.name;
in {
  system.nixos.tags =
    [ "Gnome-${config.boot.kernelPackages.kernel.modDirVersion}" ];

  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;

  environment.gnome.excludePackages = with gnome3; [
    gnome-software
    epiphany
    gnome-maps
    gedit
    gnome-todo
    gnome-contacts
    gnome-packagekit
  ];
  services.gnome.gnome-user-share.enable = false;
  services.gnome.tracker-miners.enable = false;
  services.gnome.tracker.enable = false;

  environment.systemPackages =
    [ gnome3.gnome-tweaks pkgs.networkmanagerapplet ];

  systemd.packages = [ touchegg ];
  systemd.services.touchegg.wantedBy = [ "multi-user.target" ];

  revive.specifications.user.boxes = [
    {
      src = /Programs/gnome/data/keyrings;
      dst = "/home/${mainUser}/.local/share/keyrings";
    }
    {
      src = /Programs/gnome/data/geary;
      dst = "/home/${mainUser}/.local/share/geary";
    }
    {
      src = /Programs/gnome/state/goa;
      dst = "/home/${mainUser}/.config/goa-1.0";
    }
    {
      src = /Programs/gnome/state/geary;
      dst = "/home/${mainUser}/.config/geary";
    }
  ];
}
