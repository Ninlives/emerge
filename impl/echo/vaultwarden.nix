{
  config,
  inputs,
  ...
}: let
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  dp = inputs.values.secret;
  srv = dp.host.private.services.vaultwarden;
in {
  services.nginx.virtualHosts."${srv.fqdn}" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/".proxyPass = "http://127.0.0.1:${toString srv.port}";
      "/notifications/hub/negotiate".proxyPass = "http://127.0.0.1:${toString srv.port}";
      "/notifications/hub" = {
        proxyPass = "http://127.0.0.1:${toString srv.ext.websocket-port}";
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
      domain = "https://${srv.fqdn}";
      signupsAllowed = false;
      emergencyAccessAllowed = false;
      websocketEnabled = true;
      websocketAddress = "127.0.0.1";
      websocketPort = srv.ext.websocket-port;
      rocketAddress = "127.0.0.1";
      rocketPort = srv.port;
    };
    environmentFile = tpl.vaultwarden.path;
  };

  users.users.vaultwarden.uid = 955;
  users.groups.vaultwarden.gid = 955;
  revive.specifications.system.boxes = [
    {
      src = /Services/vaultwarden;
      dst = /var/lib/bitwarden_rs;
      user = config.users.users.vaultwarden.name;
      group = config.users.groups.vaultwarden.name;
    }
  ];
}
