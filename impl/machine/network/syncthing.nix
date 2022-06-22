{ config, pkgs, fn, var, ... }:
let
  scrt = config.sops.secrets;
  dp = config.secrets.decrypted;
in {
  services.syncthing = {
    enable = true;
    user = var.user.name;
    openDefaultPorts = true;
    dataDir = fn.home ".local/share/syncthing";
    cert = scrt."syncthing/cert.pem".path;
    key = scrt."syncthing/key.pem".path;
    devices.server.id = dp.syncthing.server.id;

    folders.vaultwarden = {
      path = fn.home "Secrets/vaultwarden";
      devices = [ "server" ];
    };

    folders.note = {
      path = fn.home "Documents/Zettelkasten";
      devices = [ "server" ];
    };
  };

  revive.specifications.user.boxes = [{
    src = /Programs/syncthing;
    dst = fn.home ".local/share/syncthing";
  }];
}
