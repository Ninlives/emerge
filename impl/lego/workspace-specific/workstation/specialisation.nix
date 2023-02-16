{ config, lib, ... }:
with lib;
let dp = config.secrets.decrypted;
in {
  specialisation.workstation.configuration = { config, ... }: {
    workspace.identity = "workstation";
    workspace.user.name = dp.workstation.username;
    workspace.user.home = "/home/${dp.workstation.username}";
    workspace.user.uid = 2048;
    workspace.chestVolume = "workstation";
    workspace.hostName = dp.workstation.hostname;

    boot.loader.grub.configurationName = "Work Station";
    services.xserver.displayManager.defaultSession = "gnome-xorg";

    system.activationScripts.update-ca-certs = stringAfter [ "etc" ] ''
      mkdir -p /etc/ssl/ca-anchors
      cat /etc/ssl/certs/ca-certificates.crt > /etc/ssl/ca-anchors/ca-certificates.crt
      rm /etc/ssl/certs/ca-certificates.crt
      rm /etc/ssl/certs/ca-bundle.crt

      for cert in $(find /etc/ssl/ca-anchors -name '*.crt');do
        cat "$cert" >> /etc/ssl/certs/ca-certificates.crt
      done
      cp /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-bundle.crt
    '';

    revive.specifications.system.boxes = [{
      src = /Data/ca-anchors;
      dst = /etc/ssl/ca-anchors;
    }];
  };
}
