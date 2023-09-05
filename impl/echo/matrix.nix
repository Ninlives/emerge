{
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit (config.lib.path) persistent;
  dp = inputs.values.secret;
  inherit (dp.host.public) domain;
  inherit (dp.host.public.services.matrix) fqdn port;
  public_baseurl = "https://${fqdn}";
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  scrt = config.sops.secrets;

  clientConfig = {
    "m.server".base_url = public_baseurl;
    "m.homeserver".base_url = public_baseurl;
    "org.matrix.msc3575.proxy".url = "https://${dp.host.public.services.matrix-sync.fqdn}";
  };
  serverConfig."m.server" = "${fqdn}:443";
  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
in {
  services.matrix-synapse = {
    enable = true;
    withJemalloc = true;
    dataDir = "${persistent.data}/matrix";
    settings = {
      inherit public_baseurl;
      server_name = domain;
      signing_key_path = scrt."matrix/signing-key".path;

      enable_search = true;
      dynamic_thumbnails = true;
      allow_public_rooms_over_federation = true;

      enable_registration = true;
      registration_requires_token = true;

      listeners = [
        {
          bind_addresses = ["127.0.0.1"];
          inherit port;
          tls = false;
          type = "http";
          x_forwarded = true;
          resources = [
            {
              compress = true;
              names = ["client" "federation"];
            }
          ];
        }
      ];

      media_retention = {
        remote_media_lifetime = "14d";
      };

      experimental_features = {
        msc3266_enabled = true;
      };
    };

    sliding-sync = {
      enable = true;
      environmentFile = tpl.sliding-sync.path;
      settings = {
        SYNCV3_SERVER = config.services.matrix-synapse.settings.public_baseurl;
        SYNCV3_LOG_LEVEL = "trace";
        SYNCV3_PPROF = "127.0.0.1:6060";
      };
    };
  };
  systemd.services.matrix-synapse.serviceConfig = {
    CPUQuota = "50%";
    MemoryMax = "1G";
  };

  environment.systemPackages = [pkgs.wget];

  services.nginx.virtualHosts = {
    ${domain} = {
      forceSSL = true;
      enableACME = true;
      locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
      locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
    };
    ${fqdn} = {
      forceSSL = true;
      enableACME = true;
      locations."/_matrix".proxyPass = "http://127.0.0.1:${toString port}";
      locations."/_synapse/client".proxyPass = "http://127.0.0.1:${toString port}";
    };
    ${dp.host.public.services.matrix-sync.fqdn} = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://${config.services.matrix-synapse.sliding-sync.settings.SYNCV3_BINDADDR}";
    };
  };

  services.postgresql = {
    ensureDatabases = ["matrix-synapse"];
    ensureUsers = [
      {
        name = "matrix-synapse";
        ensurePermissions."DATABASE \"matrix-synapse\"" = "ALL PRIVILEGES";
      }
    ];
  };

  sops.secrets."matrix/signing-key" = with config.users; {
    owner = users.matrix-synapse.name;
    group = groups.matrix-synapse.name;
  };
  sops.templates.sliding-sync.content = ''
    SYNCV3_SECRET=${plh."matrix/sync-v3-secret"}
  '';

  systemd.tmpfiles.rules = with config.users; [
    "d ${config.services.matrix-synapse.dataDir} 0700 ${users.matrix-synapse.name} ${groups.matrix-synapse.name} -"
  ];
  revive.specifications.system.boxes = [
    {
      src = /Data/matrix-sliding-sync;
      dst = /var/lib/private/matrix-sliding-sync;
    }
  ];
}
