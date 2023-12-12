{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs) gnome;
  inherit (lib) mkForce;
  home = path: "${config.profile.user.home}/${path}";
in {
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.job.logToFile = mkForce false;

  systemd.services.display-manager.preStart = ''
    ${pkgs.coreutils}/bin/mkdir -p /run/gdm/.config/
    ${pkgs.coreutils}/bin/cp ${config.profile.user.home}/.config/monitors.xml /run/gdm/.config/monitors.xml
    ${pkgs.coreutils}/bin/chown gdm:gdm /run/gdm/.config/monitors.xml
  '';

  environment.gnome.excludePackages = with gnome; [
    gnome-software
    epiphany
    gnome-maps
    gnome-contacts
    gnome-packagekit
    gnome-music
    pkgs.gnome-photos
  ];
  programs.geary.enable = false;
  services.packagekit.enable = false;
  services.gnome.gnome-user-share.enable = false;
  services.gnome.tracker-miners.enable = false;
  services.gnome.tracker.enable = false;

  services.gnome.sushi.enable = true;

  environment.systemPackages = [gnome.gnome-tweaks pkgs.networkmanagerapplet];

  services.touchegg.enable = true;

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
