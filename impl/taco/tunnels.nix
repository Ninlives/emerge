{ config, ... }:
let
  plh = config.sops.placeholder;
  dp = config.secrets.decrypted;
in {
  rathole.tunnels = {
    immich = {
      token = plh."rathole/token/immich";
      port = dp.immich.port;
    };
    jellyfin = {
      token = plh."rathole/token/jellyfin";
      port = dp.jellyfin.port;
    };
  };
}
