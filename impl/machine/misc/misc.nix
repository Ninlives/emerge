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
  users.users.${var.user.name} = {
    inherit (var.user) home shell;
    createHome = true;
    isNormalUser = true;
    extraGroups = var.user.groups;
    hashedPassword = config.secrets.decrypted.hashed-password;
  };
  system.stateVersion = "18.09";
}
