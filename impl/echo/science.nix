{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  dp = inputs.values.secret;

  reddit = "${dp.host.private.services.libreddit.fqdn}";
  cache = "${dp.host.private.services.cache.fqdn}";
  libredditHost = "${config.services.redlib.address}:${
    toString config.services.redlib.port
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
  mkInbound = port: password: path: {
    inherit port;
    listen = "127.0.0.1";
    protocol = "trojan";
    settings = {
      clients = [
        {
          inherit password;
        }
      ];
    };
    streamSettings = {
      network = "ws";
      wsSettings = {inherit path;};
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

  services.nginx.virtualHosts.${cache} = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "https://cache.nixos.org";
  };
  services.nginx.virtualHosts.${reddit} = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/".proxyPass = "http://${libredditHost}";
      "/${dp.trojan.secret-path}" = mkProxy dp.trojan.port;
    };
  };

  services.v2ray = {
    enable = true;
    configFile = tpl.v2ray.path;
  };
  systemd.services.v2ray = {
    restartTriggers = [tpl.v2ray.file];
    serviceConfig = {
      ExecStart = [
        ""
        (pkgs.writeShellScript "start" ''
          ${pkgs.v2ray}/bin/v2ray run -config $CREDENTIALS_DIRECTORY/config.json
        '')
      ];
      LoadCredential = "config.json:${tpl.v2ray.path}";
    };
  };

  sops.templates.v2ray.content = builtins.toJSON {
    log = {
      access = "/tmp/v2ray_access.log";
      error = "/tmp/v2ray_error.log";
      loglevel = "error";
    };
    inbounds = [(mkInbound dp.trojan.port plh."trojan/password" "/${dp.trojan.secret-path}")];
    outbounds = [
      {
        tag = "free";
        protocol = "freedom";
        settings = {};
      }
      {
        tag = "tor";
        protocol = "socks";
        settings.servers = [
          {
            address = "127.0.0.1";
            port = 9050;
          }
        ];
      }
    ];
    routing = {
      domainStrategy = "IPOnDemand";
      rules = [
        {
          type = "field";
          domains = ["regexp:\\.onion$"];
          outboundTag = "tor";
        }
      ];
    };
  };

  services.tor.enable = true;
  services.tor.client.enable = true;

  services.redlib = {
    enable = true;
    address = "127.0.0.1";
    port = dp.host.private.services.libreddit.port;
    settings = {
      REDLIB_BANNER = "Cheers!";
      REDLIB_ROBOTS_DISABLE_INDEXING = "on";

      REDLIB_DEFAULT_THEME = "gruvboxdark";
      REDLIB_DEFAULT_SHOW_NSFW = "on";
      REDLIB_DEFAULT_USE_HLS = "on";
      REDLIB_DEFAULT_SUBSCRIPTIONS = lib.concatStringsSep "+" [
        "bindingofisaac"
        "commandline"
        "Cyberpunk"
        "exapunks"
        "geek"
        "homelab"
        "itsaunixsystem"
        "linux"
        "linux_gaming"
        "linuxmasterrace"
        "linuxmemes"
        "NixOS"
        "oddlysatisfying"
        "ProgrammerHumor"
        "steampunk"
        "unixporn"
        "xkcd"
        "ClockworkPi"
        "cyberDeck"
        "programming"
        "minecraft"
        "botania"
      ];
    };
  };
}
