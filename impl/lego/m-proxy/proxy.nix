{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (config.lib) proxy;

  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  dp = inputs.values.secret;

  # Template
  sniffing = {
    enabled = true;
    destOverride = ["http" "tls"];
  };

  socksInbound = port: tag: {
    inherit port tag sniffing;
    protocol = "socks";
    settings = {
      auth = "noauth";
      udp = false;
    };
  };

  template = {
    log = {
      access = "/tmp/v2ray_access.log";
      error = "/tmp/v2ray_error.log";
      loglevel = "info";
    };
    inbounds = [
      {
        port = proxy.port.http;
        tag = "http";
        protocol = "http";
        settings.allowTransparent = false;
      }
      {
        inherit sniffing;
        port = proxy.port.redir;
        tag = "transparent";
        protocol = "dokodemo-door";
        settings = {
          network = "tcp,udp";
          followRedirect = true;
        };
        streamSettings.sockopt.tproxy = "redirect";
      }
      (socksInbound proxy.port.local "proxy")
      (socksInbound proxy.port.acl "acl")
    ];

    outbounds = [
      {
        tag = "direct";
        protocol = "freedom";
        settings = {};
        streamSettings.sockopt.mark = proxy.mark;
      }
    ];

    routing = {
      domainStrategy = "IPOnDemand";
      rules = [
        {
          type = "field";
          domains = ["regexp:\\.onion$"];
          outboundTag = "proxy";
        }
        {
          type = "field";
          inboundTag = ["acl"];
          domains = ["geosite:cn"];
          outboundTag = "direct";
        }
        {
          type = "field";
          inboundTag = ["acl"];
          ip = ["geoip:cn"];
          outboundTag = "direct";
        }
        {
          type = "field";
          inboundTag = ["acl" "proxy" "transparent" "http"];
          outboundTag = "proxy";
        }
      ];
    };
  };

  common = {
    tag = "proxy";
    streamSettings.sockopt.mark = proxy.mark;
  };

  trojanConfig =
    template
    // {
      outbounds =
        template.outbounds
        ++ [
          (lib.recursiveUpdate {
              protocol = "trojan";
              settings.servers = [
                {
                  address = "${dp.host.private.services.libreddit.fqdn}";
                  port = 443;
                  password = plh."trojan/password";
                  level = 0;
                }
              ];
              streamSettings = {
                network = "ws";
                security = "tls";
                wsSettings.path = "/${dp.trojan.secret-path}";
              };
            }
            common)
        ];
    };

  mkService = path: config: srvConfig:
    {
      description = "v2ray Daemon";
      after = ["network.target"];
      script = ''
        ${pkgs.v2ray}/bin/v2ray run -config ${path}
      '';
      serviceConfig =
        {
          LimitNPROC = 500;
          LimitNOFILE = 1000000;
          DynamicUser = "yes";
          CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
          AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
          NoNewPrivileges = true;
          Restart = "on-failure";
          RestartPreventExitStatus = 23;
        }
        // srvConfig;
    }
    // config;

  mkTemplate = content: {
    content = builtins.toJSON content;
    owner = proxy.user;
    group = proxy.group;
  };

  default = config.profile.proxy.default;
in {
  lib.proxy = {
    mark = 187;
    group = "outcha";
    user = "outcha";
    address = "127.0.0.1";
    port = {
      local = 1080;
      redir = 1081;
      acl = 1082;
      http = 9080;
    };
  };

  users.groups.${proxy.group} = {};
  users.users.${proxy.user} = {
    inherit (proxy) group;
    isSystemUser = true;
  };

  sops.templates.v2ray-trojan = mkTemplate trojanConfig;
  sops.templates.v2ray-template = mkTemplate template;
  sops.templates.v2ray-common = mkTemplate common;

  systemd.services.v2ray-trojan = mkService "$CREDENTIALS_DIRECTORY/config.json" {
    wantedBy = lib.mkIf (default == "v2ray-trojan") ["multi-user.target"];
  } {LoadCredential = "config.json:${tpl.v2ray-trojan.path}";};
  systemd.services.v2ray-fallback =
    mkService "$RUNTIME_DIRECTORY/config.json" {
      wantedBy = lib.mkIf (default == "v2ray-fallback") ["multi-user.target"];
      preStart = ''
        CRED=$CREDENTIALS_DIRECTORY
        ${pkgs.jq}/bin/jq -s '.[0].outbounds += [.[1] * .[2]]|.[0]' $CRED/template $CRED/fallback $CRED/common > $RUNTIME_DIRECTORY/config.json
      '';
    } {
      RuntimeDirectory = "v2ray-fallback";
      LoadCredential = [
        "template:${tpl.v2ray-template.path}"
        "common:${tpl.v2ray-common.path}"
        "fallback:/${config.profile.disk.persist}/System/Data/proxy/v2ray/fallback.json"
      ];
    };

  # FIXME: Temporary
  networking.firewall.interfaces.virbr0.allowedTCPPorts = with proxy.port; [
    local
    acl
  ];
}
