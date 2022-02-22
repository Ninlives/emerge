{ config, pkgs, lib, constant, out-of-world, ... }:
with constant.proxy;
let
  plh = config.sops.placeholder;
  dp = config.secrets.decrypted;

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
  dokodemoInbound = port: tag: {
    inherit port tag sniffing;
    protocol = "dokodemo-door";
    settings = {
      network = "tcp,udp";
      followRedirect = true;
    };
    streamSettings.sockopt.tproxy = "redirect";
  };

  configWith = backend: {
    log = {
      access = "/tmp/v2ray_access.log";
      error = "/tmp/v2ray_error.log";
      loglevel = "info";
    };
    inbounds = [
      (dokodemoInbound port.redir "transparent")
      (dokodemoInbound port.wormhole "wormhole")
      # {
      #   listen = "127.0.0.1";
      #   port = dp.w-internal-port;
      #   tag = "wire";
      #   protocol = "dokodemo-door";
      #   settings = {
      #     address = "127.0.0.1";
      #     port = dp.w-internal-port;
      #     network = "tcp,udp";
      #   };
      # }
      (socksInbound port.local "proxy")
      (socksInbound port.acl "acl")
      (socksInbound port.reverse "tunnel")
    ];

    outbounds = [
      {
        tag = "direct";
        protocol = "freedom";
        settings = { };
        streamSettings.sockopt.mark = mark;
      }
      ({ tag = "proxy"; } // backend)
      # ({ tag = "guard"; } // (mkVmess plh.w-id dp.w-secret-path))
      (mkVmess plh."reverse-proxy/id" "/${dp.reverse-proxy.secret-path}" // {
        tag = "interconn";
      })
    ];

    routing = {
      domainStrategy = "IPOnDemand";
      rules = [
        # {
        #   type = "field";
        #   inboundTag = [ "wire" ];
        #   outboundTag = "guard";
        # }
        {
          type = "field";
          inboundTag = [ "wormhole" "tunnel" ];
          outboundTag = "interconn";
        }
        {
          type = "field";
          inboundTag = [ "acl" ];
          domain = [ "geosite:cn" ];
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

  mkVmess = id: secretPath: {
    protocol = "vmess";
    settings.vnext = [{
      address = "${dp.v2ray.host}";
      port = 443;
      users = [{
        inherit id;
        alterId = 0;
      }];
    }];
    streamSettings = {
      network = "ws";
      security = "tls";
      wsSettings.path = secretPath;
      sockopt.mark = mark;
    };
  };

  vmessBackend = mkVmess plh."v2ray/id" "/${dp.v2ray.secret-path}";

  ssBackend = {
    protocol = "shadowsocks";
    settings.servers = [{
      address = plh."shadowsocks/server";
      port = plh."shadowsocks/port";
      method = plh."shadowsocks/method";
      password = plh."shadowsocks/password";
    }];
    streamSettings.sockopt.mark = mark;
  };

  serviceConfig = {
    LimitNPROC = 500;
    LimitNOFILE = 1000000;
  };

in {
  systemd.services.v2ray = { inherit serviceConfig; };
  sops.templates.v2ray.content = builtins.toJSON (configWith vmessBackend);

  services.v2ray = {
    enable = true;
    configFile = config.sops.templates.v2ray.path;
  };

  sops.placeholder.s-port = 805429745;
  sops.templates.v2ray-ss.content = builtins.toJSON (configWith ssBackend);
  systemd.services.v2ray-ss = {
    description = "v2ray Daemon";
    after = [ "network.target" ];
    path = [ pkgs.v2ray ];
    script = ''
      exec v2ray -config ${config.sops.templates.v2ray-ss.path}
    '';
    inherit serviceConfig;
  };
}
