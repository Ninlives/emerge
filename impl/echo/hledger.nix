{config, inputs, ...}: let
  inherit (config.lib.path) persistent;
  dp = inputs.values.secret;
  srv = dp.host.private.services.hledger;
in {
  services.hledger-web = {
    enable = true;
    allow = "edit";
    stateDir = "${persistent.services}/hledger";
    journalFiles = [ "main.journal" ];
    baseUrl = "https://${srv.fqdn}";
    port = srv.port;
  };

  services.nginx.virtualHosts."${srv.fqdn}" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://${config.services.hledger-web.host}:${toString srv.port}";
        basicAuthFile = config.sops.secrets."hledger/auth".path;
      };
    };
  };
  sops.secrets."hledger/auth" = {
    owner = config.users.users.nginx.name;
    group = config.users.groups.nginx.name;
  };

  users.users.hledger.uid = 953;
  users.groups.hledger.gid = 953;
  systemd.tmpfiles.rules = with config.users; [
    "d ${config.services.hledger-web.stateDir} 0700 ${users.hledger.name} ${groups.hledger.name} -"
  ];
}
