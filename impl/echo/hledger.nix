{config, inputs, pkgs, ...}: let
  inherit (config.lib.path) persistent;
  dp = inputs.values.secret;
  srv = dp.host.private.services.hledger;

  paisaPkg = inputs.paisa.packages.${pkgs.system}.default;
  paisaSrv = dp.host.private.services.paisa;
  paisaConfInit = pkgs.writers.writeYAML "paisa.yaml" {
    journal_path = "${persistent.services}/hledger/main.journal";
    db_path = "${persistent.services}/paisa/paisa.db";
    default_currency = "CNY";
    display_precision = 2;
    locale = "en-US";
    time_zone = "Asia/Shanghai";
    strict = "yes";
  };
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

  systemd.services.paisa = {
    wantedBy = [ "multi-user.target" ];
    after = [ config.systemd.services.hledger-web.name ];
    path = [ paisaPkg pkgs.ledger ];
    script = ''
      paisa serve --config ${persistent.services}/paisa/paisa.yaml --port ${toString paisaSrv.port}
    '';
    serviceConfig = {
      User = "hledger";
      Group = "hledger";
    };
  };
  services.nginx.virtualHosts."${paisaSrv.fqdn}" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://127.0.0.1:${toString paisaSrv.port}";
  };

  users.users.hledger.uid = 953;
  users.groups.hledger.gid = 953;
  systemd.tmpfiles.rules = with config.users; [
    "d ${config.services.hledger-web.stateDir} 0700 ${users.hledger.name} ${groups.hledger.name} -"
    # systemd-tmpfiles refused to operate on files owned by root in directories owned by non-root
    "d ${persistent.services}/paisa 0700 root root -"
    "C ${persistent.services}/paisa/paisa.yaml - - - - ${paisaConfInit}"
    "z ${persistent.services}/paisa/paisa.yaml 0600 ${users.hledger.name} ${groups.hledger.name} -"
    "z ${persistent.services}/paisa 0700 ${users.hledger.name} ${groups.hledger.name} -"
  ];
}
