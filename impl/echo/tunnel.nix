{ config, ... }:
let
  plh = config.sops.placeholder;
  dp = config.secrets.decrypted;
in {
  rathole = {
    enable = true;
    role = "server";
  };

  services.nginx.virtualHosts."${dp.immich.subdomain}.${dp.host}" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString dp.immich.port}";
        extraConfig = ''
          client_max_body_size 0;
        '';
      };
    };
  };

  sops.templates.rathole.content = ''
    [server.services.ssh]
    token = "${plh."rathole/token/ssh"}"
    bind_addr = "0.0.0.0:${toString dp.ssh.port}"
  '';
  networking.firewall.allowedTCPPorts = [ dp.ssh.port dp.rathole.port ];
}
