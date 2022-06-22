{ config, var, ... }:
let
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  dp = config.secrets.decrypted;
  net = var.net.default;
  scrt = config.sops.secrets;

  mkProxy = port: {
    proxyPass = "http://127.0.0.1:${toString port}";
    proxyWebsockets = true;
    extraConfig = ''
      if ($http_upgrade != "websocket") {
        return 404;
      }
    '';
  };
  mkInbound = port: id: path: {
    inherit port;
    listen = "127.0.0.1";
    protocol = "vmess";
    settings = {
      clients = [{
        inherit id;
        alterId = 0;
      }];
    };
    streamSettings = {
      network = "ws";
      wsSettings = { inherit path; };
    };
  };
in {
  # networking.wireguard = {
  #   enable = true;
  #   interfaces.wg0 = {
  #     ips = [ "${net.server.address}/${net.server.prefixLength}" ];
  #     privateKeyFile = scrt.w-server-private-key.path;
  #     listenPort = dp.w-internal-port;
  #     peers = [{
  #       publicKey = dp.w-local-public-key;
  #       allowedIPs = [ net.subnet ];
  #       presharedKeyFile = scrt.w-preshared-key.path;
  #     }];
  #   };
  # };
  # services.nginx.streamConfig = ''
  #   server {
  #     listen 0.0.0.0:${toString dp.ssh.port};
  #     proxy_pass ${net.local.address}:${toString dp.ssh.port};
  #   }
  # '';
  # networking.firewall.allowedUDPPorts = [ dp.w-internal-port ];
  # networking.firewall.allowedTCPPorts = [ dp.ssh.port ];

  services.nginx.virtualHosts.${dp.v2ray.host} = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/".root = "/${dp.v2ray.root-location}";
      "/${dp.v2ray.secret-path}" = mkProxy dp.v2ray.internal-port;
      # "/${dp.w-secret-path}" = mkProxy dp.w-port;
      
      # Reverse proxy
      "/${dp.reverse-proxy.secret-path}" = mkProxy dp.reverse-proxy.port;
    };
  };

  services.v2ray = {
    enable = true;
    configFile = tpl.v2ray.path;
  };
  systemd.services.v2ray.restartTriggers = [ tpl.v2ray.file ];
  sops.templates.v2ray.content = builtins.toJSON {
    log = {
      access = "/tmp/v2ray_access.log";
      error = "/tmp/v2ray_error.log";
      loglevel = "info";
    };
    inbounds = [
      (mkInbound dp.v2ray.internal-port plh."v2ray/id" "/${dp.v2ray.secret-path}")
      # (mkInbound dp.w-port plh.w-id "/${dp.w-secret-path}")

      # Reverse proxy
      (mkInbound dp.reverse-proxy.port plh."reverse-proxy/id" "/${dp.reverse-proxy.secret-path}" // { tag = "tunnel"; })
    ];
    outbounds = [{
      protocol = "freedom";
      settings = { };
    }];

    # Reverse proxy
    reverse.portals = [{
      tag = "portal";
      domain = plh."reverse-proxy/domain";
    }];
    routing.rules = [{
      type = "field";
      inboundTag = "tunnel";
      outboundTag = "portal";
    }];
  };

}
