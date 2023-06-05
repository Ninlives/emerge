{ config, ... }:
let
  dp = config.secrets.decrypted;
  domain = "${dp.freshrss.subdomain}.${dp.host}";
  scrt = config.sops.secrets;
in {
  services.freshrss = {
    enable = true;
    defaultUser = "mlatus";
    passwordFile = scrt."freshrss/password".path;
    baseUrl = "https://${domain}";
    dataDir = "/chest/Services/freshrss";
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

  revive.specifications.system.boxes = [
    {
      src = /Cache/freshrss;
      dst = /var/lib/freshrss;
      user = config.users.users.freshrss.name;
      group = config.users.groups.freshrss.name;
    }
    {
      dst = /chest/Services/freshrss;
      user = config.users.users.freshrss.name;
      group = config.users.groups.freshrss.name;
    }
  ];
}
