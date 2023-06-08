{ config, ... }:
let
  dp = config.secrets.decrypted;
  domain = "${dp.kavita.subdomain}.${dp.host}";
in {
  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString dp.kavita.port}";
      proxyWebsockets = true;
    };
  };
}
