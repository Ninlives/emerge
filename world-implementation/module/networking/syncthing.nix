{ constant, config, pkgs, ... }:
let
  scrt = config.sops.secrets;
  dp = config.secrets.decrypted;
  inherit (constant.user.config) home;
in {
  services.syncthing = {
    enable = true;
    user = constant.user.name;
    openDefaultPorts = true;
    dataDir = constant.user.config.home + "/.local/share/syncthing";
    cert = scrt."syncthing/cert.pem".path;
    key = scrt."syncthing/key.pem".path;
    devices.server.id = dp.syncthing.server.id;

    folders.vaultwarden = {
      path = home + "/Secrets/vaultwarden";
      devices = [ "server" ];
    };

    folders.note = {
      path = home + "/Documents/Zettelkasten";
      devices = [ "server" ];
    };
  };

  revive.specifications.user.boxes = [{
    src = /Programs/syncthing;
    dst = "${constant.user.config.home}/.local/share/syncthing";
  }];
}
