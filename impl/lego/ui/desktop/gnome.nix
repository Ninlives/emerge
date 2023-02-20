{ config, pkgs, lib, fn, var, ... }:
let
  inherit (pkgs) gnome writeText;
  inherit (pkgs.nixos-cn) touchegg;
  inherit (lib) concatMapStringsSep mkForce;
  home = path: "${config.workspace.user.home}/${path}";
in {
  system.nixos.tags =
    [ "Gnome-${config.boot.kernelPackages.kernel.modDirVersion}" ];

  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.job.logToFile = mkForce false;

  environment.gnome.excludePackages = with gnome; [
    gnome-software
    epiphany
    gnome-maps
    gnome-contacts
    gnome-packagekit
  ];
  programs.geary.enable = false;
  services.packagekit.enable = false;
  services.gnome.gnome-user-share.enable = false;
  services.gnome.tracker-miners.enable = false;
  services.gnome.tracker.enable = false;

  services.gnome.sushi.enable = true;

  environment.systemPackages = [ gnome.gnome-tweaks pkgs.networkmanagerapplet ];

  systemd.packages = [ touchegg ];
  systemd.services.touchegg.wantedBy = [ "multi-user.target" ];

  revive.specifications.user.boxes = [
    {
      src = /Programs/gnome/data/keyrings;
      dst = home ".local/share/keyrings";
    }
    {
      src = /Programs/gnome/state/goa;
      dst = home ".config/goa-1.0";
    }
  ];
}
