{
  lib,
  config,
  ...
}:
with lib;
with lib.types; let
  cfg = config.profile;
in {
  options.profile = {
    identity = mkOption {
      type = str;
      default = "garden";
    };
    user.name = mkOption {
      type = str;
      default = "mlatus";
    };
    user.home = mkOption {
      type = path;
      default = "/home/${cfg.user.name}";
    };
    user.uid = mkOption {
      type = int;
      default = 1000;
    };
    disk.persist = mkOption {
      type = str;
      default = "garden";
    };
    disk.swap = mkOption {
      type = str;
      default = "chest";
    };
    proxy.default = mkOption {
      type = str;
      default = "v2ray-trojan";
    };
  };
}
