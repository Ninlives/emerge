{
  config,
  inputs,
  ...
}: let
  dp = inputs.values.secret;
  srv = dp.host.public.services;
  inherit (config.lib.path) persistent;
  fileDir = "${persistent.data}/misskey";
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
        locations."/".extraConfig = ''
          proxy_redirect off;
        '';
      };
    };
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
  systemd.services.misskey = {
    environment.MISSKEY_FILES_DIR = fileDir;
    serviceConfig.ReadWritePaths = fileDir;
  };
  systemd.tmpfiles.rules = with config.users; [
    "d ${fileDir} 0700 ${users.misskey.name} ${groups.misskey.name} -"
  ];
  revive.specifications.system.boxes = [
    {
      src = /Data/meilisearch;
      dst = /var/lib/private/meilisearch;
    }
  ];
}
