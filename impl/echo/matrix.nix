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
  };

  services.postgresql = {
    ensureDatabases = ["matrix-synapse"];
    ensureUsers = [
      {
        name = "matrix-synapse";
        ensureDBOwnership = true;
      }
    ];
  };

  sops.secrets."matrix/signing-key" = with config.users; {
    owner = users.matrix-synapse.name;
    group = groups.matrix-synapse.name;
  };

  systemd.tmpfiles.rules = with config.users; [
    "d ${config.services.matrix-synapse.dataDir} 0700 ${users.matrix-synapse.name} ${groups.matrix-synapse.name} -"
  ];
}
