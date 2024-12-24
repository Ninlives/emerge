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
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.displayManager.logToFile = mkForce false;

  systemd.services.display-manager.preStart = ''
    if [[ -f "${config.profile.user.home}/.config/monitors.xml" ]];then
      ${pkgs.coreutils}/bin/mkdir -p /run/gdm/.config/
      ${pkgs.coreutils}/bin/cp ${config.profile.user.home}/.config/monitors.xml /run/gdm/.config/monitors.xml
      ${pkgs.coreutils}/bin/chown gdm:gdm /run/gdm/.config/monitors.xml
    fi
  '';

  environment.gnome.excludePackages = with gnome; with pkgs; [
    gnome-software
    epiphany
    gnome-maps
    gnome-contacts
    gnome-packagekit
    gnome-music
    gnome-photos
  ];
  programs.geary.enable = false;
  services.packagekit.enable = false;
  services.gnome.gnome-user-share.enable = false;
  services.gnome.localsearch.enable = false;
  services.gnome.tinysparql.enable = false;

  services.gnome.sushi.enable = true;

  environment.systemPackages = [pkgs.gnome-tweaks pkgs.networkmanagerapplet];

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
