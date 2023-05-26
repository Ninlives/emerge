{ config, ... }:
let
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  dp = config.secrets.decrypted;
in {
  services.nginx.virtualHosts."${dp.vaultwarden.subdomain}.${dp.host}" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/".proxyPass = "http://127.0.0.1:${toString dp.vaultwarden.port}";
      "/notifications/hub/negotiate".proxyPass =
        "http://127.0.0.1:${toString dp.vaultwarden.port}";
      "/notifications/hub" = {
        proxyPass =
          "http://127.0.0.1:${toString dp.vaultwarden.websocket-port}";
        proxyWebsockets = true;
      };
    };
  };

  sops.templates.vaultwarden.content = ''
    ADMIN_TOKEN=${plh."vaultwarden/admin-token"}
  '';

  services.vaultwarden = {
    enable = true;
    config = {
      domain = "https://${dp.vaultwarden.subdomain}.${dp.host}";
      signupsAllowed = false;
      emergencyAccessAllowed = false;
      websocketEnabled = true;
      websocketAddress = "127.0.0.1";
      websocketPort = dp.vaultwarden.websocket-port;
      rocketAddress = "127.0.0.1";
      rocketPort = dp.vaultwarden.port;
    };
    environmentFile = tpl.vaultwarden.path;
  };

  users.users.vaultwarden.uid = 955;
  users.groups.vaultwarden.gid = 955;
  revive.specifications.system.boxes = [{
    src = /Services/vaultwarden;
    dst = /var/lib/bitwarden_rs;
    user = config.users.users.vaultwarden.name;
    group = config.users.groups.vaultwarden.name;
  }];
}
