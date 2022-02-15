{ config, pkgs, lib, out-of-world, constant, ... }:
let
  inherit (out-of-world) dirs;
  inherit (constant) user;
  inherit (lib)
    take concatStringsSep cleanSource mapAttrsToList splitString mkIf
    optionalString stringAfter;
  inherit (builtins) pathExists;
  inherit (pkgs) runCommand path gutenprint gutenprintBin;
in {
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

  system.activationScripts.binbash = stringAfter [ "binsh" ] ''
    mkdir -m 0755 -p /bin
    ln -sfn "${config.environment.binsh}" /bin/.bash.tmp
    mv /bin/.bash.tmp /bin/bash # atomically replace /bin/bash
  '';

  users.users."${user.name}" = user.config;
  system.stateVersion = "18.09";
}
