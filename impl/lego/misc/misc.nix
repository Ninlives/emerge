{ config, pkgs, lib, var, ... }:
with pkgs;
with lib;
{
  services.printing.enable = true;
  services.printing.drivers = [ gutenprint gutenprintBin ];

  revive.specifications.system.boxes = [
    {
      src = /Data/network-connections;
      dst = /etc/NetworkManager/system-connections;
    }
    {
      src = /Data/bluetooth;
      dst = /var/lib/bluetooth;
    }
  ];

  time.timeZone = "Asia/Shanghai";

  users.mutableUsers = false;
  users.users.${config.workspace.user.name} = {
    inherit (config.workspace.user) uid home;
    inherit (var.user) shell;
    createHome = true;
    isNormalUser = true;
    extraGroups = var.user.groups;
    passwordFile = config.sops.secrets.hashed-password.path;
  };
  sops.secrets.hashed-password.neededForUsers = true;

  system.stateVersion = "22.05";
}
