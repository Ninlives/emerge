{ constant, config, pkgs, ... }:
let
  scrt = config.sops.secrets;
  dp = config.secrets.decrypted;
in {
  services.syncthing = {
    enable = true;
    user = constant.user.name;
    openDefaultPorts = true;
    dataDir = constant.user.config.home + "/.local/share/syncthing";
    cert = scrt."syncthing/local/cert.pem".path;
    key = scrt."syncthing/local/key.pem".path;
    devices.server.id = dp.syncthing.server.id;

    folders.vaultwarden = {
      path = constant.user.config.home + "/Secrets/vaultwarden";
      devices = [ "server" ];
    };
  };

  revive.specifications.user.boxes = [{
    src = /Programs/syncthing;
    dst = "${constant.user.config.home}/.local/share/syncthing";
  }];
}
