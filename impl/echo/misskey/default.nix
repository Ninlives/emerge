{ config, lib, inputs, pkgs, ... }:
let
  dp = inputs.values.secret;
  scrt = config.sops.secrets;
  tpl = config.sops.templates;
  srv = dp.host.public.services;
  inherit (config.lib.path) persistent;
  ensureServices = services:
    assert (lib.all (s: config.systemd.services ? ${s}) services);
    map (s: "${s}.service") services;
  fileDir = "${persistent.data}/misskey";
in {
  imports = [
    inputs.misskey.nixosModules.default
    inputs.courier.nixosModules.default
  ];
  services.misskey = {
    enable = true;
    package = pkgs.misskey.overrideAttrs (p: {
      patches = p.patches or [ ] ++ [
        ./relay-announce.patch
        ./unlimited-replies.patch
        dp.patches.misskey.deepl
      ];
    });
    data.directory = fileDir;
  };
  systemd.services.misskey = {
    after = ensureServices [ "postgresql" "redis-misskey" ];
    serviceConfig = {
      MemoryMax = "1G";
      NoNewPrivileges = true;
      ProtectSystem = "full";
      ReadWritePaths = "${fileDir}";
      PrivateUsers = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectProc = "invisible";
      LockPersonality = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      CapabilityBoundingSet = "";
      ProtectHostname = true;
      SystemCallArchitectures = "native";
      UMask = "0077";
    };
  };

  environment.etc."misskey/default.yml".source = tpl.misskey.path;

  sops.templates.misskey = {
    owner = config.users.users.misskey.name;
    group = config.users.groups.misskey.name;
    content = lib.generators.toYAML { } {
      url = "https://${srv.misskey.fqdn}/";
      port = srv.misskey.port;
      db = {
        host = "/run/postgresql";
        db = "misskey";
        user = "misskey";
      };
      dbReplications = false;
      redis = {
        host = "127.0.0.1";
        port = 6379;
      };
      id = "aid";
      signToActivityPubGet = true;
      # allowedPrivateNetworks = [
      #   "127.0.0.1/32"
      # ];
    };
  };

  services.nginx.virtualHosts.${srv.misskey.fqdn} = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString srv.misskey.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
      extraConfig = ''
        proxy_redirect off;
      '';
    };
  };

  users.users.misskey.uid = 954;
  users.groups.misskey.gid = 954;
  revive.specifications.system.boxes = [{
    dst = "${fileDir}";
    user = config.users.users.misskey.name;
    group = config.users.groups.misskey.name;
  }];

  services.postgresql = {
    ensureDatabases = [ "misskey" ];
    ensureUsers = [{
      name = "misskey";
      ensurePermissions."DATABASE misskey" = "ALL PRIVILEGES";
    }];
    identMap = ''
      misskey misskey misskey
    '';
    authentication = ''
      local misskey misskey peer map=misskey
    '';
  };

  services.redis.servers.misskey = {
    enable = true;
    port = 6379;
  };

  # Relay
  services.courier = {
    enable = true;
    listenPort = srv.courier.port;
    hostName = srv.courier.fqdn;
    privKeyFile = scrt."courier/keys/private.pem".path;
    pubKeyFile = scrt."courier/keys/public.pem".path;
  };
  services.nginx.virtualHosts.${srv.courier.fqdn} = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString srv.courier.port}";
      recommendedProxySettings = true;
    };
  };
  sops.secrets."courier/keys/private.pem" = {
    owner = config.services.courier.user;
    group = config.services.courier.group;
  };
  sops.secrets."courier/keys/public.pem" = {
    owner = config.services.courier.user;
    group = config.services.courier.group;
  };
}
