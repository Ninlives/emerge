{ config, ... }:
let
  dp = config.secrets.decrypted;
  domain = "${dp.jellyfin.subdomain}.${dp.host}";
  port = toString dp.jellyfin.port;
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
