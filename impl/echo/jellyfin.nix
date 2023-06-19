{ inputs, ... }:
let
  dp = inputs.values.secret;
  domain = "${dp.host.private.services.jellyfin.fqdn}";
  port = toString dp.host.private.services.jellyfin.port;
in {
  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${port}";
      recommendedProxySettings = true;
    };
    locations."/socket" = {
      proxyPass = "http://127.0.0.1:${port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
