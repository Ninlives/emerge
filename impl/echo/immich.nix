{ config, ... }:
let
  dp = config.secrets.decrypted;
in {
  services.nginx.virtualHosts."${dp.immich.subdomain}.${dp.host}" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString dp.immich.port}";
        recommendedProxySettings = true;
        extraConfig = ''
          client_max_body_size 0;
        '';
      };
    };
  };
}
