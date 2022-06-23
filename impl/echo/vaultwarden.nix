{ config, lib, pkgs, ... }:
let
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
  dp = config.secrets.decrypted;
  scrt = config.sops.secrets;
  sync-user = config.services.syncthing.user;
  sync-group = config.services.syncthing.group;
  backupDir = "vault-backup";
  backupDirPath = "/var/lib/${backupDir}";
in {
  services.nginx.virtualHosts.${dp.vaultwarden.host} = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/".proxyPass = "http://127.0.0.1:${toString dp.vaultwarden.port}";
      "/notifications/hub/negotiate".proxyPass = "http://127.0.0.1:${toString dp.vaultwarden.port}";
      "/notifications/hub" = {
        proxyPass = "http://127.0.0.1:${toString dp.vaultwarden.websocket-port}";
        proxyWebsockets = true;
      };
    };
  };

  sops.templates.vaultwarden.content = ''
    ADMIN_TOKEN=${plh."vaultwarden/admin-token"}
  '';

  services.syncthing.folders.vaultwarden = {
    path = backupDirPath;
    devices = [ "local" ];
  };

  services.vaultwarden = {
    enable = true;
    config = {
      domain = "https://${dp.vaultwarden.host}";
      signupsAllowed = false;
      emergencyAccessAllowed = false;
      websocketEnabled = true;
      websocketAddress = "127.0.0.1";
      websocketPort = dp.vaultwarden.websocket-port;
      rocketAddress = "127.0.0.1";
      rocketPort = dp.vaultwarden.port;
    };
    environmentFile = tpl.vaultwarden.path;
    backupDir = backupDirPath;
    webVaultPackage = pkgs.vaultwarden-vault.overrideAttrs (_: {
      src = pkgs.fetchurl {
        url = "https://github.com/dani-garcia/bw_web_builds/releases/download/v2.25.1b/bw_web_v2.25.1b.tar.gz";
        sha256 = "sha256-YZu/aeQJohmrsNMTVudQtRE8GT3FUxp0IDU7VWAgAAE=";
      };
    });
  };

  systemd.services.backup-vaultwarden.serviceConfig = {
    Group = sync-group;
    StateDirectory = backupDir;
    StateDirectoryMode = "0770";
  };

  systemd.services.backup-vaultwarden.aliases = lib.mkForce [];
  systemd.timers.backup-vaultwarden.aliases = lib.mkForce [];
}
