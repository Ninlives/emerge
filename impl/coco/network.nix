{ config, pkgs, inputs, ... }:
let
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  dp = inputs.values.secret;
in {
  networking.networkmanager.enable = true;
  services.openssh.listenAddresses = [{
    addr = "127.0.0.1";
    inherit (dp.ssh) port;
  }];

  rathole = {
    enable = true;
    role = "client";
  };
  sops.templates.rathole.content = ''
    [client.services.ssh]
    token = "${plh."rathole/token/ssh"}"
    local_addr = "127.0.0.1:${toString dp.ssh.port}"
  '';

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
    inbounds = [{
      inherit (dp.rathole) port;
      sniffing = {
        enabled = true;
        destOverride = [ "http" "tls" ];
      };
      protocol = "dokodemo-door";
      settings = {
        network = "tcp,udp";
        address = "127.0.0.1";
        inherit (dp.rathole) port;
      };
    }];
    outbounds = [{
      protocol = "trojan";
      settings.servers = [{
        address = "${dp.host.private.libreddit.fqdn}";
        port = 443;
        password = plh."trojan/password";
        level = 0;
      }];
      streamSettings = {
        network = "ws";
        security = "tls";
        wsSettings.path = "/${dp.trojan.secret-path}";
      };
    }];
  };
  services.smartdns = {
    enable = true;
    settings = {
      address = [
        "/${dp.host.private.libreddit.fqdn}/#6"
      ];
    };
  };
  networking.resolvconf.useLocalResolver = true;
}
