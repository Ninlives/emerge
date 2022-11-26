{ config, lib, ... }:
with lib;
let
  plh = config.sops.placeholder;
  dp = config.secrets.decrypted;
  nfsPorts = [ 111 2049 4000 4001 4002 20048 ];
  mkNFSTunnels = type:
    listToAttrs (map (port: {
      name = "nfs-${type}-${toString port}";
      value = mkNFSTunnel type port;
    }) nfsPorts);
  mkNFSTunnel = type: port: {
    inherit type port;
    token = plh."rathole/token/nfs";
  };
in {
  rathole.tunnels = {
    immich = {
      token = plh."rathole/token/immich";
      port = dp.immich.port;
    };
  } // (mkNFSTunnels "tcp") // (mkNFSTunnels "udp");
}
