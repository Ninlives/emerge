{ config, var, pkgs, ... }:
let
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  dp = config.secrets.decrypted;
  scrt = config.sops.secrets;

  domain = "${dp.libreddit.subdomain}.${dp.host}";
  libredditHost = "${config.services.libreddit.address}:${
      toString config.services.libreddit.port
    }";
  mkProxy = port: {
    proxyPass = "http://127.0.0.1:${toString port}";
    proxyWebsockets = true;
    extraConfig = ''
      if ($http_upgrade != "websocket") {
        proxy_pass http://${libredditHost};
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
  # services.nginx.streamConfig = ''
  #   server {
  #     listen 0.0.0.0:${toString dp.ssh.port};
  #     proxy_pass ${net.local.address}:${toString dp.ssh.port};
  #   }
  # '';
  # networking.firewall.allowedUDPPorts = [ dp.w-internal-port ];
  # networking.firewall.allowedTCPPorts = [ dp.ssh.port ];

  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/".proxyPass = "http://${libredditHost}";
      "/${dp.v2ray.secret-path}" = mkProxy dp.v2ray.port;
    };
  };

  services.v2ray = {
    enable = true;
    configFile = tpl.v2ray.path;
  };
  systemd.services.v2ray = {
    restartTriggers = [ tpl.v2ray.file ];
    serviceConfig = {
      ExecStart = [
        ""
        (pkgs.writeShellScript "start" ''
          ${pkgs.v2ray}/bin/v2ray run -config $CREDENTIALS_DIRECTORY/config
        '')
      ];
      LoadCredential = "config:${tpl.v2ray.path}";
    };
  };

  sops.templates.v2ray.content = builtins.toJSON {
    log = {
      access = "/tmp/v2ray_access.log";
      error = "/tmp/v2ray_error.log";
      loglevel = "info";
    };
    inbounds =
      [ (mkInbound dp.v2ray.port plh."v2ray/id" "/${dp.v2ray.secret-path}") ];
    outbounds = [
      {
        tag = "free";
        protocol = "freedom";
        settings = { };
      }
      {
        tag = "tor";
        protocol = "socks";
        settings.servers = [{
          address = "127.0.0.1";
          port = 9050;
        }];
      }
    ];
    routing = {
      domainStrategy = "IPOnDemand";
      rules = [
        {
          type = "field";
          domains = [ "regexp:\\.onion$" ];
          outboundTag = "tor";
        }
      ];
    };
  };

  services.tor.enable = true;
  services.tor.client.enable = true;

  services.libreddit = {
    enable = true;
    address = "127.0.0.1";
    port = dp.libreddit.port;
  };
}
