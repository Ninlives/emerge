{ config, inputs, lib, ... }:
let
  plh = config.sops.placeholder;
  dp = inputs.values.secret;
in {
  rathole.tunnels = lib.listToAttrs (map (srv: {
    name = srv;
    value = {
      token = plh."rathole/token/${srv}";
      port = dp.host.private.services.${srv}.port;
    };
  }) [ "immich" "jellyfin" "kavita" ]);
}
