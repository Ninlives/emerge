{ inputs, ... }:
let
  dp = inputs.values.secret;
  domain = "${dp.host.private.services.kavita.fqdn}";
in {
  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString dp.host.private.services.kavita.port}";
      proxyWebsockets = true;
    };
  };
}
