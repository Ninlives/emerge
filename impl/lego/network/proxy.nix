{ config, pkgs, lib, var, ... }:
with var.proxy;
let
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  scrt = config.sops.secrets;
  dp = config.secrets.decrypted;
  net = var.net.default;

  # Template
  sniffing = {
    enabled = true;
    destOverride = [ "http" "tls" ];
  };

  socksInbound = port: tag: {
    inherit port tag sniffing;
    listen = address;
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
        inherit sniffing;
        port = port.redir;
        tag = "transparent";
        protocol = "dokodemo-door";
        settings = {
          network = "tcp,udp";
          followRedirect = true;
        };
        streamSettings.sockopt.tproxy = "redirect";
      }
      (socksInbound port.local "proxy")
      (socksInbound port.acl "acl")
    ];

    outbounds = [{
      tag = "direct";
      protocol = "freedom";
      settings = { };
      streamSettings.sockopt.mark = mark;
    }];

    routing = {
      domainStrategy = "IPOnDemand";
      rules = [
        {
          type = "field";
          domains = [ "regexp:\\.onion$" ];
          outboundTag = "proxy";
        }
        {
          type = "field";
          inboundTag = [ "acl" ];
          domains = [ "geosite:cn" ];
          outboundTag = "direct";
        }
        {
          type = "field";
          inboundTag = [ "acl" ];
          ip = [ "geoip:cn" ];
          outboundTag = "direct";
        }
        {
          type = "field";
          inboundTag = [ "acl" "proxy" "transparent" ];
          outboundTag = "proxy";
        }
      ];
    };
  };

  common = {
    tag = "proxy";
    streamSettings.sockopt.mark = mark;
  };

  trojanConfig = template // {
    outbounds = template.outbounds ++ [
      (lib.recursiveUpdate {
        protocol = "trojan";
        settings.servers = [{
          address = "${dp.libreddit.subdomain}.${dp.host}";
          port = 443;
          password = plh."trojan/password";
          level = 0;
        }];
        streamSettings = {
          network = "ws";
          security = "tls";
          wsSettings.path = "/${dp.trojan.secret-path}";
        };
      } common)
    ];
  };

  mkService = path: config: srvConfig:
    {
      description = "v2ray Daemon";
      after = [ "network.target" ];
      script = ''
        ${pkgs.v2ray}/bin/v2ray run -config $CREDENTIALS_DIRECTORY/config
      '';
      serviceConfig = {
        LimitNPROC = 500;
        LimitNOFILE = 1000000;
        DynamicUser = "yes";
        CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
        AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
        NoNewPrivileges = true;
        Restart = "on-failure";
        RestartPreventExitStatus = 23;
        LoadCredential = "config:${path}";
      } // srvConfig;
    } // config;

  mkTemplate = content: {
    content = builtins.toJSON content;
    owner = var.proxy.user;
    group = var.proxy.group;
  };

in {

  users.groups.${var.proxy.group} = { };
  users.users.${var.proxy.user} = {
    inherit (var.proxy) group;
    isSystemUser = true;
  };

  sops.templates.v2ray-trojan = mkTemplate trojanConfig;
  sops.templates.v2ray-template = mkTemplate template;
  sops.templates.v2ray-common = mkTemplate common;

  systemd.services.v2ray-trojan = mkService "$CREDENTIALS_DIRECTORY/config" {
    wantedBy = [ "multi-user.target" ];
  } { LoadCredential = "config:${tpl.v2ray-trojan.path}"; };
  systemd.services.v2ray-fallback = mkService "$RUNTIME_DIRECTORY/config.json" {
    preStart = ''
      CRED=$CREDENTIALS_DIRECTORY
      ${pkgs.jq}/bin/jq -s '.[0].outbounds += [.[1] * .[2]]|.[0]' $CRED/template $CRED/fallback $CRED/common > $RUNTIME_DIRECTORY/config.json
    '';
  } {
    RuntimeDirectory = "v2ray-fallback";
    LoadCredential = [
      "template:${tpl.v2ray-template.path}"
      "common:${tpl.v2ray-common.path}"
      "fallback:/chest/System/Data/v2ray/fallback.json"
    ];
  };
}
