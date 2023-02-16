{ config, nixosConfig, var, lib, ... }: {
  config = lib.mkIf (nixosConfig.workspace.identity == "private") {
    dconf.settings = {
      "system/proxy".mode = "manual";
      "system/proxy/socks" = {
        host = var.proxy.address;
        port = var.proxy.port.acl;
      };
    };
  };
}
