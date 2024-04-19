{config, inputs, ...}: let
  inherit (config.lib.path) persistent;
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  dp = inputs.values.secret;
  srv = dp.host.private.services.hledger;
in {
  services.hledger-web = {
    enable = true;
    allow = "add";
    stateDir = "${persistent.services}/hledger";
    journalFiles = [ "main.journal" ];
    baseUrl = "https://${srv.fqdn}";
    port = srv.port;
  };

  services.nginx.virtualHosts."${srv.fqdn}" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/".proxyPass = "http://${config.services.hledger-web.host}:${toString srv.port}";
    };
  };

  users.users.hledger.uid = 953;
  users.groups.hledger.gid = 953;
  systemd.tmpfiles.rules = with config.users; [
    "d ${config.services.hledger-web.stateDir} 0700 ${users.hledger.name} ${groups.hledger.name} -"
  ];
}
