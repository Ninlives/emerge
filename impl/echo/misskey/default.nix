{
  inputs,
  ...
}: let
  dp = inputs.values.secret;
  srv = dp.host.public.services;
in {
  services.misskey = {
    enable = true;
    settings = {
      id = "aid";
      dbReplications = false;
      signToActivityPubGet = true;
    };
    database.createLocally = true;
    redis.createLocally = true;
    meilisearch.createLocally = true;
    reverseProxy = {
      enable = true;
      host = srv.misskey.fqdn;
      ssl = true;
      webserver.nginx = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          client_max_body_size 256M;
        '';
      };
    };
  };

  systemd.services.misskey.serviceConfig = {
    RuntimeMaxSec = 4 * 60 * 60;
    Restart = "always";
  };

  users.users.misskey = {
    group = "misskey";
    uid = 954;
  };
  users.groups.misskey.gid = 954;

  services.postgresql = {
    identMap = ''
      misskey misskey misskey
    '';
    authentication = ''
      local misskey misskey peer map=misskey
    '';
  };

  # Persistent
  revive.specifications.system.boxes = [
    {
      src = /Data/meilisearch;
      dst = /var/lib/private/meilisearch;
    }
    {
      src = /Data/misskey;
      dst = /var/lib/private/misskey;
    }
  ];
}
