{inputs, ...}: let
  dp = inputs.values.secret;
  srv = dp.host.private.services.immich;
in {
  services.nginx.virtualHosts."${srv.fqdn}" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString srv.port}";
        recommendedProxySettings = true;
        extraConfig = ''
          client_max_body_size 0;
        '';
      };
    };
  };
}
