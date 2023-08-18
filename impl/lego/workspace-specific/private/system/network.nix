{ config, lib, ... }: {
  config = lib.mkIf (config.workspace.identity == "private") {
    services.smartdns.enable = true;
    networking.resolvconf.useLocalResolver = true;
  };
}
