{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.types; let
  cfg = config.rathole;
  tpl = config.sops.templates;
  dp = inputs.values.secret;
in {
  options.rathole = {
    enable = mkEnableOption "rathole";
    role = mkOption {type = enum ["server" "client"];};
    tunnels = mkOption {
      type = attrsOf (submodule {
        options = {
          type = mkOption {
            type = enum ["tcp" "udp"];
            default = "tcp";
          };
          port = mkOption {type = int;};
          token = mkOption {type = str;};
        };
      });
    };
  };

  config = mkIf cfg.enable {
    sops.templates.rathole.content =
      ''
        [${cfg.role}]
        ${
          if cfg.role == "server"
          then "bind_addr"
          else "remote_addr"
        } = "127.0.0.1:${toString dp.rathole.port}"
      ''
      + concatStringsSep "\n" (mapAttrsToList (name: tunnel: ''
          [${cfg.role}.services.${name}]
          type = "${tunnel.type}"
          token = "${tunnel.token}"
          ${
            if cfg.role == "server"
            then "bind_addr"
            else "local_addr"
          } = "127.0.0.1:${toString tunnel.port}"
        '')
        cfg.tunnels);

    systemd.services.rathole = {
      description = "Rat Hole";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      script = ''
        ${pkgs.rathole}/bin/rathole $CREDENTIALS_DIRECTORY/config.toml
      '';
      serviceConfig.LoadCredential = "config.toml:${tpl.rathole.path}";
    };
    environment.systemPackages = [pkgs.lsof];
    networking.firewall.allowedTCPPorts = [dp.rathole.port];
  };
}
