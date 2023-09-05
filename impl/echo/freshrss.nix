{
  config,
  inputs,
  ...
}: let
  inherit (config.lib.path) persistent;
  dp = inputs.values.secret;
  domain = "${dp.host.private.services.freshrss.fqdn}";
  scrt = config.sops.secrets;
in {
  services.freshrss = {
    enable = true;
    defaultUser = "mlatus";
    passwordFile = scrt."freshrss/password".path;
    baseUrl = "https://${domain}";
    dataDir = "${persistent.services}/freshrss";
    virtualHost = domain;
  };
  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;
  };
  sops.secrets."freshrss/password" = {
    owner = config.users.users.freshrss.name;
    group = config.users.groups.freshrss.name;
  };

  users.users.freshrss = {
    uid = 997;
    group = "freshrss";
    isSystemUser = true;
  };
  users.groups.freshrss.gid = 997;
  revive.specifications.system.boxes = [
    {
      src = /Cache/freshrss;
      dst = /var/lib/freshrss;
      user = config.users.users.freshrss.name;
      group = config.users.groups.freshrss.name;
    }
  ];
  systemd.tmpfiles.rules = with config.users; [
    "d ${persistent.services}/freshrss 0700 ${users.freshrss.name} ${groups.freshrss.name} -"
  ];
}
