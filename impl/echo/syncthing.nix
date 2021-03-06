{ config, ... }:
let
  scrt = config.sops.secrets;
  dp = config.secrets.decrypted;
in {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    cert = scrt."syncthing/cert.pem".path;
    key = scrt."syncthing/key.pem".path;
    devices.local.id = dp.syncthing.local.id;
    # relay.enable = false;
    # relay.providedBy = "Somebody";
  };

  # networking.firewall.allowedTCPPorts = with config.services.syncthing.relay; [
  #   port
  #   statusPort
  # ];
}
